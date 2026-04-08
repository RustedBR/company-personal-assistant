---
name: office-files
description: Manipulate Office files (CSV, PPTX, DOCX, XLSX, XML) using Python libraries
---

## Python Libraries Available

Install required libraries with:
```bash
pip install pandas openpyxl python-docx python-pptx lxml
```

## Supported Formats & Libraries

| Format | Library | Use Case |
|--------|---------|----------|
| CSV | pandas | Read, write, analyze, filter data |
| XLSX | pandas + openpyxl | Read/write Excel, formulas, formatting |
| DOCX | python-docx | Create and edit Word documents |
| PPTX | python-pptx | Create PowerPoint presentations |
| XML | lxml / xml.etree | Parse and generate XML files |

## CSV Manipulation

```python
import pandas as pd

# Read CSV
df = pd.read_csv('file.csv')

# Filter data
filtered = df[df['column'] > value]

# Write CSV
df.to_csv('output.csv', index=False)
```

## Excel (XLSX) Manipulation

```python
import pandas as pd
from openpyxl import load_workbook

# Read Excel
df = pd.read_excel('file.xlsx', sheet_name='Sheet1')

# Write Excel with multiple sheets
with pd.ExcelWriter('output.xlsx') as writer:
    df1.to_excel(writer, sheet_name='Sheet1')
    df2.to_excel(writer, sheet_name='Sheet2')

# Advanced Excel operations with openpyxl
wb = load_workbook('file.xlsx')
ws = wb.active
ws['A1'] = 'Value'
wb.save('file.xlsx')
```

## Word (DOCX) Manipulation

```python
from docx import Document

doc = Document()
doc.add_heading('Title', 0)
doc.add_paragraph('Content here')
doc.save('output.docx')
```

## PowerPoint (PPTX) Manipulation

```python
from pptx import Presentation

prs = Presentation()
slide = prs.slides.add_slide(prs.slide_layouts[1])
title = slide.shapes.title
title.text = "Title"
prs.save('output.pptx')
```

## XML Manipulation

```python
from lxml import etree

# Create XML
root = etree.Element('root')
child = etree.SubElement(root, 'child')
child.text = 'content'
print(etree.tostring(root, pretty_print=True).decode())
```

## Best Practices

1. Make backup copies before modifying files
2. Use absolute paths
3. Save work frequently
4. For complex operations, test on small samples first
5. Use pandas for data analysis tasks
6. Openpyxl for precise cell-level control
