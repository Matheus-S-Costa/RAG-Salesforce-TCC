global with sharing class ChatbotController {
    private static final String CHAT_GPT_KEY = System.label.chatGPTAPIkey;
    private static final String endpoint = 'https://api.openai.com/v1/chat/completions';

    global class FlowInput {
        @InvocableVariable(required = true)
        public String requestMessage;
    }

    global class FlowOutput {
        @InvocableVariable
        public String returnMessage;
    }

    private static List<FlowOutput> getMessage(HttpResponse response){
        FlowOutput flowOutput = new FlowOutput();

        Map<String, Object> gptResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
        List<Object> choices = (List<Object>)gptResponse.get('choices');
        System.debug(choices);
        for (Object choice : choices) {

            Map<String, Object> objectChoice = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(choice));
            
            for(String fieldNameChoice : objectChoice.keySet()){
                system.debug(fieldNameChoice);
                Map<String, Object> objectMessage = new Map<String, Object>();
                if (fieldNameChoice == 'message'){
                    objectMessage = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objectChoice.get(fieldNameChoice)));
                }
                for(String fieldNameMessage : objectMessage.keySet()){
                    
                    if(fieldNameMessage == 'content'){
                        system.debug(fieldNameMessage);
                        flowOutput.returnMessage = string.valueOf(objectMessage.get(fieldNameMessage));
                        break;
                    }
                }
            }
        }

        List<FlowOutput> flowOutputs = new List<FlowOutput>();
        flowOutputs.add(flowOutput);
        
        return flowOutputs;
    }

    @InvocableMethod(label = 'Interagir com IA' description='Envie a pergunta para Open AI e receba a resposta.')
    global static List<FlowOutput> callApi(List<FlowInput> message) {
        System.debug(message);
        HttpRequest request = new HttpRequest();

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + CHAT_GPT_KEY);

        
        String prompt = message + '. Por favor, se baseie em um contexto voltado para o Salesforce. Caso não seja possível, favor informar previamente.';
        request.setBody('{"model": "gpt-4o-mini","messages": [{"role": "user", "content": "'+ prompt +'"}], "temperature": 0.7}');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response.getBody());

        return getMessage(response);
    }
}