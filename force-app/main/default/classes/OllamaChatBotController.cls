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

    private static List<FlowOutput> getMessage(HttpResponse response) {
        FlowOutput flowOutput = new FlowOutput();
        String responseBody = response.getBody();

        flowOutput.output = responseBody;
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

        req.setTimeout(120000); 

        Http http = new Http();
        HttpResponse response = http.send(req);

        return getMessage(response);
    }
}
