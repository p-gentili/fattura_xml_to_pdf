# Fattura XML to PDF
A simple Python script for formatting and printing any Italian plain XML invoice to HTML and PDF.

## Getting started
Development:
```bash
python3 -m venv venv
source venv/bin/activate
pip3 -e install .
```

Install (via _pipx_):
```bash
pipx install .
```

Run:
```bash
fattura2pdf <path_to_xml>
```

## Fogli di stile
- [SDI](https://www.fatturapa.gov.it/it/norme-e-regole/documentazione-fattura-elettronica/formato-fatturapa/)
    - [1.2.2](https://www.fatturapa.gov.it/export/documenti/fatturapa/v1.2.2/Foglio_di_stile_fattura_ordinaria_ver1.2.2.xsl)
