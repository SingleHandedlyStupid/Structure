// Example: click-to-copy for code blocks
document.querySelectorAll('pre code').forEach(block => {
    block.addEventListener('click', () => {
        navigator.clipboard.writeText(block.innerText);
        alert('Code copied!');
    });
});
