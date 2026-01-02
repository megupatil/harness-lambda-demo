exports.handler = async (event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from Harness Canary Deployment! Version 1'),
    };
    return response;
};
