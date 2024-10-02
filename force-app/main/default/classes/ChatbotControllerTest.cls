@isTest
public class ChatbotControllerTest {

    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"choices": [{"message": {"content": "Aqui está a resposta da IA"}}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testCallApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        List<ChatbotController.FlowInput> inputs = new List<ChatbotController.FlowInput>();
        ChatbotController.FlowInput input = new ChatbotController.FlowInput();
        input.questionMessage = 'O que é Salesforce?';
        inputs.add(input);

        Test.startTest();
        List<ChatbotController.FlowOutput> result = ChatbotController.callApi(inputs);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('Aqui está a resposta da IA', result[0].returnMessage);
    }
}