global with sharing class DeleteOllamaResponsesBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime limite = System.now().addDays(-3);
        String query = 'SELECT Id FROM Ollama_Response__c WHERE CreatedDate <= :limite';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Ollama_Response__c> scope) {
        try {
            delete scope;
            System.debug('Excluindo registros: ' + scope.size());
        } catch (Exception e) {
            System.debug('Erro ao excluir registros: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch concluído. Todos os registros com mais de 1 dia foram excluídos.');
    }
}
