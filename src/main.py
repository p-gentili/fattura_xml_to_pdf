import argparse
from lxml import etree
from io import BytesIO
from xhtml2pdf import pisa


def convert(xml_file: str, xsl_file: str):
    try:
        with open(xml_file, "rb") as xml_input:
            xml_tree = etree.parse(xml_input)

        with open(xsl_file, "rb") as xsl_input:
            xsl_root = etree.XML(xsl_input.read())
    except FileNotFoundError as exc:
        raise SystemExit("Cannot open input files.") from exc

    # Apply the XSL transformation to the XML data
    transform = etree.XSLT(xsl_root)
    result_tree = transform(xml_tree)

    # Convert the result to HTML
    html_content = etree.tostring(result_tree)

    with open("output.pdf", "wb") as pdf_output:
        pisa.CreatePDF(BytesIO(html_content), pdf_output)


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--xml", required=True)
    parser.add_argument("--xsl", required=True)

    args = parser.parse_args(argv)

    convert(args.xml, args.xsl)


if __name__ == "__main__":
    main()
