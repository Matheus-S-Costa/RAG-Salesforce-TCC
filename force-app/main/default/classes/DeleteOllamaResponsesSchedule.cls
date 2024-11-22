global class DeleteOllamaResponsesSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        DeleteOllamaResponsesBatch deleteBatch = new DeleteOllamaResponsesBatch();
        Database.executeBatch(deleteBatch);
    }
}