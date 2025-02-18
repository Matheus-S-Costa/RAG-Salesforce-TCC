global with sharing class OllamaChatBotController {
    private static final String endpoint = 'https://projetoartemis.com.br/api/artemis.php';

    global class FlowInput {
        @InvocableVariable(required = true)
        public String message;
    }

    global class FlowOutput {
        @InvocableVariable
        public String output;
    }

    private static FlowOutput getMessage(HttpResponse response, String requestMessage) {
        FlowOutput flowOutput = new FlowOutput();
        String content = response.getBody();

        Ollama_Response__c apiResponse = new Ollama_Response__c();
        apiResponse.Message__c = requestMessage;
        apiResponse.Name = 'Chatbot - ' + System.now().format() + ' - ' +  UserInfo.getName();

        if (content != null) {
            flowOutput.output = content;
            apiResponse.Response__c = content;
            apiResponse.Status__c = 'Concluído';
        } else {
            flowOutput.output = 'Resposta vazia ou não esperada da API Ollama.';
            apiResponse.Response__c = flowOutput.output;
            apiResponse.Status__c = 'Erro';
        }

        try {
            insert apiResponse;
        } catch (Exception e) {
            System.debug('Erro ao salvar resposta na APIResponse__c: ' + e.getMessage());
        }

        return flowOutput;
    }

    @InvocableMethod(label = 'Interagir com Ollama' description = 'Envie a pergunta para Ollama AI e receba a resposta.')
    public static List<FlowOutput> callApiOllama(List<FlowInput> inputs) {
        List<FlowOutput> outputs = new List<FlowOutput>();

        if (inputs.isEmpty()) {
            FlowOutput errorOutput = new FlowOutput();
            errorOutput.output = 'A mensagem não pode estar vazia.';
            outputs.add(errorOutput);
            return outputs;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        
        String pergunta = inputs[0].message;

        Map<String, String> promptMap = new Map<String, String>{'prompt' => pergunta};
        String promptBody = JSON.serialize(promptMap);
        req.setBody(promptBody);

        req.setTimeout(120 * 1000); 

        HttpResponse res;
        try {
            res = new Http().send(req);

            if (res.getStatusCode() == 200) {
                FlowOutput flowOutput = getMessage(res, pergunta);
                outputs.add(flowOutput);
            } else {
                FlowOutput errorOutput = new FlowOutput();
                errorOutput.output = 'Erro ao se comunicar com a API Ollama: ' + res.getStatus();
                outputs.add(errorOutput);
            }
        } catch (Exception e) {
            FlowOutput errorOutput = new FlowOutput();
            errorOutput.output = 'Erro ao fazer a requisição: ' + e.getMessage();
            outputs.add(errorOutput);
        }

        return outputs;
    }
}