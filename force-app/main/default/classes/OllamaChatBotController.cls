global with sharing class OllamaChatBotController {
    private static final String endpoint = 'callout:OllamaAPI/artemis.php';

    global class FlowInput {
        @InvocableVariable(required = true)
        public String message;
    }

    global class FlowOutput {
        @InvocableVariable
        public String output;
    }

    private static FlowOutput getMessage(HttpResponse response) {
        FlowOutput flowOutput = new FlowOutput();

        Map<String, Object> ollamaResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        String content = (String) ollamaResponse.get('response');

        if (content != null) {
            flowOutput.output = content;
        } else {
            flowOutput.output = 'Resposta vazia ou não esperada da API Ollama.';
        }

        return flowOutput;
    }

    @InvocableMethod(label = 'Interagir com Ollama' description = 'Envie a pergunta para Ollama AI e receba a resposta.')
    public static List<FlowOutput> callApiOllama(List<FlowInput> inputs) {
        List<FlowOutput> outputs = new List<FlowOutput>();

        if (inputs.isEmpty()) {
            throw new IllegalArgumentException('A mensagem não pode estar vazia.');
        }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');

            String body = inputs[0].message; 
            String prompt = JSON.serialize('"prompt": ' + body);
            String requestBody = JSON.serialize(new Map<String, Object> { 'prompt: ' => inputs[0].message });

            req.setBody(requestBody);

            req.setTimeout(60 * 1000); 

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                outputs.add(getMessage(res));
            } else {
                throw new CalloutException('Falha ao chamar a API: ' + res.getStatusCode() + ' - ' + res.getStatus());
            }

        return outputs;
    }
}
