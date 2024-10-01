import { LightningElement } from 'lwc';
import getChatbotResponse from '@salesforce/apex/ChatbotController.getChatbotResponse';

export default class ChatbotComponent extends LightningElement {
    userQuery = '';
    chatbotResponse = '';

    handleQueryChange(event) {
        this.userQuery = event.target.value;
    }

    handleGetResponse() {
        getChatbotResponse({ userQuery: this.userQuery })
            .then((result) => {
                this.chatbotResponse = result;
            })
            .catch((error) => {
                console.error('Erro ao obter a resposta do chatbot: ', error);
            });
    }
}
