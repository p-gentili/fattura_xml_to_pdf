import argparse
import os
from io import BytesIO
from pathlib import Path

import lxml.etree as ET
from xhtml2pdf import pisa


def convert(xml_file: Path, xsl_file: Path):
    """Apply the style and convert to HTML/PDF."""

    dom = ET.parse(xml_file)
    xslt = ET.parse(xsl_file)

    transform = ET.XSLT(xslt)
    newdom = transform(dom)

    html_content = ET.tostring(newdom, pretty_print=True)

    with open(f"{xml_file.stem}.html", "wb") as output:
        output.write(html_content)

    with open(f"{xml_file.stem}.pdf", "wb") as output:
        pisa.CreatePDF(BytesIO(html_content), output)


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("xml")
    parser.add_argument("--xsl", default="sdi", choices=["sdi", "aruba"])

    args = parser.parse_args(argv)
    xsl_file = Path(os.path.dirname(__file__)) / f"styles/{args.xsl}.xsl"

    convert(Path(args.xml), xsl_file)


if __name__ == "__main__":
    main()
