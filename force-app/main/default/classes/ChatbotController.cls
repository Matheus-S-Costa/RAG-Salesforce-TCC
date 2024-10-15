global with sharing class ChatbotController {
    private static final String CHAT_GPT_KEY = System.label.chatGPTAPIkey;
    private static final String endpoint = 'https://api.openai.com/v1/chat/completions';

    global class FlowInput {
        @InvocableVariable(required = true)
        public String questionMessage;
    }

    global class FlowOutput {
        @InvocableVariable
        public String returnMessage;
    }

    private static List<FlowOutput> getMessage(HttpResponse response){
        FlowOutput flowOutput = new FlowOutput();

        Map<String, Object> gptResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> choices = (List<Object>) gptResponse.get('choices');
        
        if (!choices.isEmpty()) {
            Map<String, Object> choice = (Map<String, Object>) choices[0];
            Map<String, Object> message = (Map<String, Object>) choice.get('message');
            
            flowOutput.returnMessage = (String) message.get('content');
        }

        return new List<FlowOutput> { flowOutput };
    }


    @InvocableMethod(label = 'Interagir com IA' description='Envie a pergunta para Open AI e receba a resposta.')
    global static List<FlowOutput> callApi(List<FlowInput> message) {
        HttpRequest request = new HttpRequest();

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + CHAT_GPT_KEY);

        
        String prompt = message[0].questionMessage + '. Por favor, se baseie em um contexto voltado para o Salesforce. Caso não seja possível, favor informar previamente.';
        request.setBody('{"model": "gpt-4o-mini","messages": [{"role": "user", "content": "'+ prompt +'"}], "temperature": 0.5}');
        
        Http http = new Http();
        HttpResponse response = http.send(request);

        return getMessage(response);
    }
}