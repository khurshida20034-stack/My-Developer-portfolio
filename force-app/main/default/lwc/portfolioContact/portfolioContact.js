import { LightningElement, api } from 'lwc';
import submitMessage from '@salesforce/apex/PortfolioController.submitMessage';

export default class PortfolioContact extends LightningElement {
    @api email;
    @api whatsappHref;

    senderName = '';
    senderEmail = '';
    senderPhone = '';
    subject = '';
    message = '';
    isSending = false;
    isSent = false;
    errorMessage = '';

    get mailHref() {
        return this.email ? 'mailto:' + this.email : null;
    }

    get sendLabel() {
        return this.isSending ? 'Sending...' : 'Send message';
    }

    handleChange(event) {
        this[event.target.name] = event.target.value;
        this.isSent = false;
    }

    async handleSubmit(event) {
        event.preventDefault();
        this.errorMessage = '';
        const fields = Array.from(this.template.querySelectorAll('input, textarea'));
        const allValid = fields.every((field) => field.reportValidity());
        if (!allValid) {
            return;
        }
        this.isSending = true;
        try {
            await submitMessage({
                senderName: this.senderName,
                senderEmail: this.senderEmail,
                senderPhone: this.senderPhone,
                subject: this.subject,
                message: this.message
            });
            this.isSent = true;
            this.senderName = '';
            this.senderEmail = '';
            this.senderPhone = '';
            this.subject = '';
            this.message = '';
            this.template.querySelector('form').reset();
        } catch (error) {
            this.errorMessage = (error && error.body && error.body.message) || 'Your message could not be sent. Please try again.';
        } finally {
            this.isSending = false;
        }
    }
}
