import http from '@/api/http';

export default (uuid: string): Promise<any[]> => {
    return new Promise((resolve, reject) => {
        http.post(`/api/client/servers/${uuid}/logs`)
            .then(response => {
                resolve(response.data)
            })
            .catch(reject);
    });
};