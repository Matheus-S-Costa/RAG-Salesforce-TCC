@isTest
public class LeadControllerTest {
    
    @isTest
    static void testCreateLeadSuccess() {
        LeadController.FlowInput input = new LeadController.FlowInput();
        input.firstName = 'John';
        input.lastName = 'Doe';
        input.title = 'CEO';
        input.company = 'Salesforce';
        input.email = 'john.doe@salesforce.com';
        input.phone = '123456789';

        List<LeadController.FlowInput> inputs = new List<LeadController.FlowInput>{input};
        
        Test.startTest();
        List<LeadController.FlowOutput> outputs = LeadController.createLead(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Deve haver um output para o input fornecido.');
        System.assertEquals('Status: Successo', outputs[0].status, 'O status deve ser de sucesso.');
        System.assertEquals('Lead criado com sucesso', outputs[0].message, 'A mensagem de sucesso deve ser retornada.');

        List<Lead> leads = [SELECT FirstName, LastName, Title, Company, Email, Phone FROM Lead];
        System.assertEquals(1, leads.size(), 'Deve haver um lead inserido.');
        System.assertEquals('John', leads[0].FirstName, 'O nome deve corresponder.');
        System.assertEquals('Doe', leads[0].LastName, 'O sobrenome deve corresponder.');
        System.assertEquals('CEO', leads[0].Title, 'O título deve corresponder.');
        System.assertEquals('Salesforce', leads[0].Company, 'A empresa deve corresponder.');
        System.assertEquals('john.doe@salesforce.com', leads[0].Email, 'O email deve corresponder.');
        System.assertEquals('123456789', leads[0].Phone, 'O telefone deve corresponder.');
    }

    @isTest
    static void testCreateLeadError() {
        LeadController.FlowInput input = new LeadController.FlowInput();
        input.Email = 'test@test'; 

        List<LeadController.FlowInput> inputs = new List<LeadController.FlowInput>{input};

        Test.startTest();
        List<LeadController.FlowOutput> outputs = LeadController.createLead(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Deve haver um output para o input fornecido.');
        System.assertEquals('Status: Error', outputs[0].status, 'O status deve ser de erro.');
    }
}