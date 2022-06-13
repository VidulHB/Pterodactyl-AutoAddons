import React, { useEffect, useState } from 'react';
import { ServerContext } from '@/state/server';
import ServerContentBlock from '@/components/elements/ServerContentBlock';
import tw from 'twin.macro';
import FlashMessageRender from '@/components/FlashMessageRender';
import useFlash from '@/plugins/useFlash';
import ContentBox from '@/components/elements/ContentBox';
import Field from '@/components/elements/Field';
import { number, object, string } from 'yup';
import { Field as FormikField, Form, Formik, FormikHelpers } from 'formik';
import Spinner from '@/components/elements/Spinner';
import Select from '@/components/elements/Select';
import FormikFieldWrapper from '@/components/elements/FormikFieldWrapper';
import { httpErrorToHuman } from '@/api/http';
import GreyRowBox from '@/components/elements/GreyRowBox';
import getAll from '@/api/server/logs/getAll';

interface SearchValues {
    query: string;
    size: number;
}

export default () => {
    const uuid = ServerContext.useStoreState(state => state.server.data!.uuid);

    const { addError, clearFlashes } = useFlash();
    const [ loading, setLoading ] = useState(true);
    const [ logs, setLogs ] = useState<any[]>([]);

    useEffect(() => {
        setLoading(!logs);
        clearFlashes('server:logs');

        getAll(uuid)
        .then(logList => {
            setLogs(logList.slice(0, 25));
        })
        .catch(error => {
            console.error(error);
            addError({ key: 'server:logs', message: httpErrorToHuman(error) });
        })
        .then(() => setLoading(false));
    }, []);

    const submit = ({ query, size }: SearchValues, { setSubmitting }: FormikHelpers<SearchValues>) => {
        clearFlashes('server:logs');

        if(!query){
            getAll(uuid)
            .then(logList => {
                setLogs(logList.slice(0, size));
            })
            .catch(error => {
                console.error(error);
                addError({ key: 'server:logs', message: httpErrorToHuman(error) });
            })
            .then(() => setSubmitting(false));
        }else{
            getAll(uuid)
            .then(logList => {
                var loggList: any[] = [];
                logList.forEach(log => {
                    if(log.message.includes(query)){
                        loggList.push(log);
                    }else if(log.time.includes(query)){
                        loggList.push(log);
                    }else if(log.user.includes(query)){
                        loggList.push(log);
                    }
                });
                setLogs(loggList.slice(0, size));
            })
            .catch(error => {
                console.error(error);
                addError({ key: 'server:logs', message: httpErrorToHuman(error) });
            })
            .then(() => setSubmitting(false));
        }
    };

    return (
        <ServerContentBlock title={'Logs'} css={tw`flex flex-wrap`}>
            <div css={tw`w-full`}>
                <FlashMessageRender byKey={'server:logs'} css={tw`mb-4`} />
                <div css={tw`px-1 py-2`}>
                    <Formik
                        onSubmit={submit}
                        initialValues={{ query: '', size: 25 }}
                        validationSchema={object().shape({
                            query: string(),
                            size: number().required(),
                        })}
                    >
                        <Form>
                            <div css={tw`flex flex-wrap`}>
                                <div css={tw`w-full sm:w-8/12 sm:pr-4`}>
                                    <Field
                                        name={'query'}
                                        placeholder={'Search Term'}
                                    />
                                </div>
                                <div css={tw`w-full sm:w-4/12`}>
                                    <FormikFieldWrapper name={'size'}>
                                        <FormikField as={Select} name={'size'}>
                                            <option value={10}>10 Results</option>
                                            <option value={25}>25 Results</option>
                                            <option value={50}>50 Results</option>
                                            <option value={100}>100 Results</option>
                                        </FormikField>
                                    </FormikFieldWrapper>
                                </div>
                            </div>
                        </Form>
                    </Formik>
                </div>
            </div>
            {(!logs && loading) ?
                <div css={tw`w-full`}>
                    <Spinner size={'large'} centered />
                </div>
                :
                <>
                    {logs?.length < 1 ?
                        <>
                            <div css={tw`w-full`}>
                                <ContentBox>
                                    <p css={tw`text-center text-sm text-neutral-400`}>
                                        No logs were found.
                                    </p>
                                </ContentBox>
                            </div>
                        </>
                        :
                        (
                            <>
                                {logs?.map((item, key) => (
                                    <GreyRowBox $hoverable={false} css={tw`mb-2 w-full`}>
                                        <div css={tw`flex-1 ml-4`}>
                                            <p css={tw`text-sm`}>{item.message}</p>
                                            <p css={tw`mt-1 text-2xs text-neutral-500 uppercase select-none`}>Description</p>
                                        </div>
                                        <div css={tw`flex-1 ml-4`}>
                                            <p css={tw`text-sm`}>{item.time}</p>
                                            <p css={tw`mt-1 text-2xs text-neutral-500 uppercase select-none`}>Time</p>
                                        </div>
                                        <div css={tw`flex-1 ml-4`}>
                                            <p css={tw`text-sm`}>{item.user}</p>
                                            <p css={tw`mt-1 text-2xs text-neutral-500 uppercase select-none`}>User</p>
                                        </div>
                                    </GreyRowBox>
                                ))}
                            </>
                        )
                    }
                </>
            }
        </ServerContentBlock>
    );
};