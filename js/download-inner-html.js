function downloadElement(handle) {
  const b64Data = btoa(
    unescape(
      encodeURIComponent(handle)
    )
  )

  const shadowButton = document.createElement('a');
  const mouseClickEvent = new MouseEvent('click');

  shadowButton.download = 'doc.html';
  shadowButton.href = 'data:text/html;base64,' + b64Data;
  shadowButton.dispatchEvent(mouseClickEvent);

}

// Example - download Google Spreadsheet
downloadElement(document.documentElement.innerHTML);