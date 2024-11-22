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

    public class ResponseWrapper {
        public String response; 
    }

    private static List<FlowOutput> getMessage(HttpResponse response) {
        FlowOutput flowOutput = new FlowOutput();
        String responseBody = response.getBody();

        String contentType = response.getHeader('Content-Type');
        if (contentType != null && contentType.contains('application/json')) {
            try {
                ResponseWrapper deserializedResponse = (ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
                if (deserializedResponse != null && deserializedResponse.response != null) {
                    flowOutput.output = deserializedResponse.response;
                } else {
                    flowOutput.output = 'Erro: Resposta não contém a chave "response".';
                }
            } catch (Exception e) {
                flowOutput.output = 'Erro ao processar a resposta JSON: ' + e.getMessage();
            }
        } else {
            flowOutput.output = responseBody;
        }

        return new List<FlowOutput> { flowOutput };
    }

    @InvocableMethod(label = 'Interagir com Ollama' description = 'Envie a pergunta para Ollama AI e receba a resposta.')
    public static List<FlowOutput> callApiOllama(List<FlowInput> inputs) {
        List<FlowOutput> outputs = new List<FlowOutput>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        String pergunta = inputs[0].message;

        String reqBody = '{"prompt": "' + pergunta + '"}';
        req.setBody(reqBody);

        req.setTimeout(110000); 

        Http http = new Http();
        HttpResponse response = http.send(req);

        return getMessage(response);
    }
}
