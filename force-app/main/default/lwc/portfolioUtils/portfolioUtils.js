const SAFE_URL = /^https?:\/\//i;

export function safeUrl(value) {
    return value && SAFE_URL.test(value) ? value : null;
}

export function formatMonth(isoDate) {
    if (!isoDate) {
        return '';
    }
    const date = new Date(isoDate + 'T00:00:00Z');
    return new Intl.DateTimeFormat('en', { month: 'short', year: 'numeric', timeZone: 'UTC' }).format(date);
}

export function formatDate(isoDate) {
    if (!isoDate) {
        return '';
    }
    const date = new Date(isoDate + 'T00:00:00Z');
    return new Intl.DateTimeFormat('en', { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' }).format(date);
}
