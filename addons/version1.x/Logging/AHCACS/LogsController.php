<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\DB;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;

use Illuminate\Support\Facades\Log;

class LogsController extends ClientApiController
{

    /**
     * LogsControllers constructor.
     */
    public function __construct()
    {

    }

    /**
     * Returns all logs for this server.
     *
     * @throws \Pterodactyl\Exceptions\Http\Connection\DaemonConnectionException
     */
    public function index(Server $server): array
    {
        $logs = DB::table('audit_logs')->where("server_id", "=", $server->id)->orderBy("id", "desc")->get();
        $logList = array();

        foreach($logs as $log){
            $message = "";
            $user = DB::table('users')->where("id", "=", $log->user_id)->first();
            $metadata = json_decode($log->metadata);

            if(is_null($user)) continue;

            if($log->action == "server:filesystem.download"){
                $message = $metadata->file." got downloaded";
            }else if($log->action == "server:filesystem.write"){
                $message = $metadata->file." got edited";
            }else if($log->action == "server:filesystem.delete"){
                if(count($metadata->files) > 1){
                    $message = join(", ", $metadata->files)." got deleted in ".$metadata->root;
                }else{
                    $message = $metadata->root.$metadata->files[0]." got deleted";
                }
            }else if($log->action == "server:filesystem.rename"){
                $message = $metadata->root.$metadata->files[0]->from." got renamed to ".$metadata->files[0]->to.".";
            }else if($log->action == "server:filesystem.compress"){
                if(count($metadata->files) > 1){
                    $message = join(", ", $metadata->files)." got compressed in ".$metadata->root;
                }else{
                    $message = $metadata->root.$metadata->files[0]." got compressed";
                }
            }else if($log->action == "server:filesystem.decompress"){
                $message = $metadata->root.$metadata->files." got decompressed";
            }else if($log->action == "server:filesystem.pull"){
                $message = $metadata->url." got pulled into ".$metadata->directory;
            }else if($log->action == "server:backup.started"){
                $backup_name = DB::table('backups')->where("uuid", "=", $metadata->backup_uuid)->first()->name;
                $message = "Backup ".$backup_name." got created";
            }else if($log->action == "server:backup.deleted"){
                $backup_name = DB::table('backups')->where("uuid", "=", $metadata->backup_uuid)->first()->name;
                $message = "Backup ".$backup_name." got deleted";
            }else if($log->action == "server:backup.downloaded"){
                $backup_name = DB::table('backups')->where("uuid", "=", $metadata->backup_uuid)->first()->name;
                $message = "Backup ".$backup_name." got downloaded";
            }else if($log->action == "server:backup.locked"){
                $backup_name = DB::table('backups')->where("uuid", "=", $metadata->backup_uuid)->first()->name;
                $message = "Backup ".$backup_name." got locked";
            }else if($log->action == "server:backup.unlocked"){
                $backup_name = DB::table('backups')->where("uuid", "=", $metadata->backup_uuid)->first()->name;
                $message = "Backup ".$backup_name." got unlocked";
            }else if($log->action == "server:backup.restore.started"){
                $backup_name = DB::table('backups')->where("uuid", "=", $metadata->backup_uuid)->first()->name;
                $message = "Backup ".$backup_name." got restored";
            }else if($log->action == "server:database.create"){
                $message = "Database ".$metadata->database_name." got created";
            }else if($log->action == "server:database.password.rotate"){
                $message = "Password of database ".$metadata->database_name." got rotated";
            }else if($log->action == "server:database.delete"){
                $message = "Database ".$metadata->database_name." got deleted";
            }else if($log->action == "server:allocation.set.primary"){
                $message = "Allocation port ".$metadata->allocation_port." got set as primary";
            }else if($log->action == "server:allocation.delete"){
                $message = "Allocation port ".$metadata->allocation_port." got deleted";
            }else if($log->action == "server:allocation.create"){
                $message = "Allocation port ".$metadata->allocation_port." got created";
            }else if($log->action == "server:power"){
                $message = "Power state got set to ".$metadata->signal;
            }else if($log->action == "server:schedule.create"){
                $message = "Schedule ".$metadata->schedule_name." got created";
            }else if($log->action == "server:schedule.update"){
                $message = "Schedule ".$metadata->schedule_name." got updated";
            }else if($log->action == "server:schedule.delete"){
                $message = "Schedule ".$metadata->schedule_name." got deleted";
            }else if($log->action == "server:schedule.run"){
                $message = "Schedule ".$metadata->schedule_name." got executed";
            }else if($log->action == "server:schedule.task.create"){
                $message = "Task inside schedule ".$metadata->schedule_name." got created";
            }else if($log->action == "server:schedule.task.update"){
                $message = "Task inside schedule ".$metadata->schedule_name." got updated";
            }else if($log->action == "server:schedule.task.delete"){
                $message = "Task inside schedule ".$metadata->schedule_name." got deleted";
            }else if($log->action == "server:settings.name.update"){
                $message = "Server renamed from ".$metadata->old." to ".$metadata->new;
            }else if($log->action == "server:settings.reinstall"){
                $message = "Server got reinstalled";
            }else if($log->action == "server:settings.image.update"){
                $message = "Docker image changed from ".$metadata->old." to ".$metadata->new;
            }else if($log->action == "server:subuser.create"){
                $message = "Subuser ".$metadata->user." got created";
            }else if($log->action == "server:subuser.update"){
                $message = "Subuser ".$metadata->user." got updated";
            }else if($log->action == "server:subuser.delete"){
                $message = "Subuser ".$metadata->user." got deleted";
            }else{
                $message = "Unknown log ".json_encode($metadata);
            }

            array_push($logList, array(
                "user" => $user->email,
                "time" => $log->created_at,
                "message" => $message,
            ));
        }

        return $logList;
    }
}