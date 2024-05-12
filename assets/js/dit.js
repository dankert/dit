document.querySelectorAll('code.source').forEach((block) => {

    let language = block.dataset.language;
    hljs.configure({
        noHighlightRe: /^line$/i,
        languages: [language]
    });
    console.debug("using language: "+language);
    //hljs.highlightElement(block);
});
