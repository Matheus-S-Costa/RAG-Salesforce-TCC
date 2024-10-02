global with sharing class LeadController {
    
    global class FlowInput {
        @InvocableVariable(required = true)
        public String firstName;
        @InvocableVariable(required = true)
        public String lastName;
        @InvocableVariable(required = true)
        public String title;
        @InvocableVariable
        public String company;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String phone;
    }

    global class FlowOutput {
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label = 'Criar Lead' description = 'Cria um Lead com as informações fornecidas pelo chatbot.')
    global static List<FlowOutput> createLead(List<FlowInput> inputs) {
        List<FlowOutput> outputs = new List<FlowOutput>();
        List<Lead> leadsToInsert = new List<Lead>();  

        for (FlowInput input : inputs) {
            FlowOutput output = new FlowOutput();
            
            try {
                Lead newLead = new Lead();
                newLead.title = input.title;
                newLead.FirstName = input.firstName;
                newLead.LastName = input.lastName;
                newLead.Company = input.company != null ? input.company : 'Unknown'; 
                newLead.Email = input.email;
                newLead.Phone = input.phone;

                leadsToInsert.add(newLead);

                output.status = 'Status: Successo';
                output.message = 'Lead criado com sucesso';

            } catch (Exception e) {
                output.status = 'Status: Error';
                output.message = 'Erro ao processar o lead: ' + e.getMessage();
            }

            outputs.add(output);
        }

        if (!leadsToInsert.isEmpty()) {
            try {
                insert leadsToInsert;
            } catch (Exception e) {
                for (FlowOutput output : outputs) {
                    output.status = 'Status: Error';
                    output.message = 'Erro ao inserir os leads: ' + e.getMessage();
                }
            }
        }
        return outputs;
    }
}