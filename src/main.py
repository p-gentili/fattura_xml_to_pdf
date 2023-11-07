import argparse
import os
from lxml import etree
from io import BytesIO
from xhtml2pdf import pisa


def convert(xml_tree: bytes, xsl_root: bytes):
    """Apply the style and convert to PDF."""

    transform = etree.XSLT(xsl_root)
    result_tree = transform(xml_tree)
    html_content = etree.tostring(result_tree)

    with open("output.pdf", "wb") as pdf_output:
        pisa.CreatePDF(BytesIO(html_content), pdf_output)


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("xml")
    parser.add_argument("--xsl", default="sdi", choices=["sdi"])

    args = parser.parse_args(argv)

    xsl_file = os.path.join(os.path.dirname(__file__), f"styles/{args.xsl}.xsl")

    try:
        with open(args.xml, "rb") as xml_input:
            xml_tree = etree.parse(xml_input)

        with open(xsl_file, "rb") as xsl_input:
            xsl_root = etree.XML(xsl_input.read())
    except FileNotFoundError as exc:
        raise SystemExit("Cannot open input files.") from exc

    convert(xml_tree, xsl_root)


if __name__ == "__main__":
    main()
