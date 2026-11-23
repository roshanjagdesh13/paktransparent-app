// Export utilities for data download

export const exportToCSV = (data: any[], filename: string) => {
  if (data.length === 0) {
    console.error('No data to export');
    return;
  }

  // Get headers from first object
  const headers = Object.keys(data[0]);
  
  // Create CSV content
  const csvContent = [
    headers.join(','), // Header row
    ...data.map(row => 
      headers.map(header => {
        const value = row[header];
        // Handle values with commas, quotes, or newlines
        if (typeof value === 'string' && (value.includes(',') || value.includes('"') || value.includes('\n'))) {
          return `"${value.replace(/"/g, '""')}"`;
        }
        return value;
      }).join(',')
    )
  ].join('\n');

  // Create blob and download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  
  link.setAttribute('href', url);
  link.setAttribute('download', `${filename}.csv`);
  link.style.visibility = 'hidden';
  
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

export const exportToJSON = (data: any, filename: string) => {
  const jsonContent = JSON.stringify(data, null, 2);
  
  const blob = new Blob([jsonContent], { type: 'application/json;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  
  link.setAttribute('href', url);
  link.setAttribute('download', `${filename}.json`);
  link.style.visibility = 'hidden';
  
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

export const exportToPDF = (elementId: string, filename: string) => {
  // For PDF export, we'll use a simple approach with print
  // In production, you'd use a library like jsPDF or html2pdf
  
  const element = document.getElementById(elementId);
  if (!element) {
    console.error('Element not found');
    return;
  }

  // Open print dialog
  window.print();
  
  console.log('PDF export initiated for:', filename);
};

export const exportToExcel = (data: any[], filename: string) => {
  // For Excel, we'll export as CSV with .xlsx extension
  // In production, you'd use a library like xlsx or exceljs
  
  if (data.length === 0) {
    console.error('No data to export');
    return;
  }

  const headers = Object.keys(data[0]);
  
  // Create tab-separated values (TSV) for better Excel compatibility
  const tsvContent = [
    headers.join('\t'),
    ...data.map(row => 
      headers.map(header => {
        const value = row[header];
        if (typeof value === 'string' && value.includes('\t')) {
          return `"${value}"`;
        }
        return value;
      }).join('\t')
    )
  ].join('\n');

  const blob = new Blob([tsvContent], { type: 'application/vnd.ms-excel;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  
  link.setAttribute('href', url);
  link.setAttribute('download', `${filename}.xls`);
  link.style.visibility = 'hidden';
  
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

export const generateReportPDF = (reportData: {
  title: string;
  dateRange: string;
  sections: Array<{
    title: string;
    content: string;
    data?: any[];
  }>;
}) => {
  // Create a formatted HTML document for printing
  const printWindow = window.open('', '_blank');
  
  if (!printWindow) {
    alert('Please allow popups to download the report');
    return;
  }

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>${reportData.title}</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          padding: 40px;
          color: #333;
        }
        h1 {
          color: #004b00;
          border-bottom: 3px solid #004b00;
          padding-bottom: 10px;
        }
        h2 {
          color: #286c1e;
          margin-top: 30px;
        }
        .header {
          text-align: center;
          margin-bottom: 40px;
        }
        .date-range {
          color: #666;
          font-size: 14px;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin: 20px 0;
        }
        th, td {
          border: 1px solid #ddd;
          padding: 12px;
          text-align: left;
        }
        th {
          background-color: #004b00;
          color: white;
        }
        tr:nth-child(even) {
          background-color: #f9f9f9;
        }
        .footer {
          margin-top: 50px;
          text-align: center;
          color: #666;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>${reportData.title}</h1>
        <p class="date-range">${reportData.dateRange}</p>
        <p class="date-range">Generated on: ${new Date().toLocaleString()}</p>
      </div>
      
      ${reportData.sections.map(section => `
        <section>
          <h2>${section.title}</h2>
          <p>${section.content}</p>
          ${section.data && section.data.length > 0 ? `
            <table>
              <thead>
                <tr>
                  ${Object.keys(section.data[0]).map(key => `<th>${key}</th>`).join('')}
                </tr>
              </thead>
              <tbody>
                ${section.data.map(row => `
                  <tr>
                    ${Object.values(row).map(value => `<td>${value}</td>`).join('')}
                  </tr>
                `).join('')}
              </tbody>
            </table>
          ` : ''}
        </section>
      `).join('')}
      
      <div class="footer">
        <p>Pakistan Public Budget Tracker & Transparency Platform</p>
        <p>PakTransparent - Government of Pakistan</p>
      </div>
      
      <script>
        window.onload = () => {
          window.print();
          // Optionally close after printing
          // window.onafterprint = () => window.close();
        };
      </script>
    </body>
    </html>
  `;

  printWindow.document.write(html);
  printWindow.document.close();
};
