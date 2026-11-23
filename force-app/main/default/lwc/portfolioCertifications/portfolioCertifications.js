import { LightningElement, api } from 'lwc';
import { safeUrl, formatMonth } from 'c/portfolioUtils';

export default class PortfolioCertifications extends LightningElement {
    _certifications = [];

    @api
    get certifications() {
        return this._certifications;
    }
    set certifications(value) {
        this._certifications = value || [];
    }

    get hasCertifications() {
        return this._certifications.length > 0;
    }

    get cards() {
        return this._certifications.map((cert) => ({
            id: cert.Id,
            name: cert.Name,
            issuer: cert.Issuer__c,
            issued: formatMonth(cert.Issue_Date__c),
            credentialId: cert.Credential_ID__c,
            url: safeUrl(cert.Credential_URL__c)
        }));
    }
}
