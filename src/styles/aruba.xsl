<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:a="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2" >
	<xsl:output method="html" doctype-system="about:legacy-compat" indent="yes" encoding="utf-8" />

	<xsl:decimal-format name="euroFormat" decimal-separator="," grouping-separator="."/>

	<xsl:variable name="ritenutaPrevList">
		<Item>
			<Tipo>RT03</Tipo>
			<Label>INPS</Label>
		</Item>
		<Item>
			<Tipo>RT04</Tipo>
			<Label>ENASARCO</Label>
		</Item>
		<Item>
			<Tipo>RT05</Tipo>
			<Label>ENPAM</Label>
		</Item>
		<Item>
			<Tipo>RT06</Tipo>
			<Label>ALTRO</Label>
		</Item>
	</xsl:variable>

	<xsl:variable name="natureList">
		<Item>
			<Tipo>N1</Tipo>
			<Label>Totale escluso IVA</Label>
		</Item>
		<Item>
			<Tipo>N2</Tipo>
			<Label>Totale non soggetto IVA</Label>
		</Item>
		<Item>
			<Tipo>N2.1</Tipo>
			<Label>Totale non soggetto ad IVA ai sensi degli artt. da 7 a 7-septies del DPR 633/72</Label>
		</Item>
		<Item>
			<Tipo>N2.2</Tipo>
			<Label>Totale non soggetto - altri casi</Label>
		</Item>
		<Item>
			<Tipo>N3</Tipo>
			<Label>Totale non imponibile IVA</Label>
		</Item>
		<Item>
			<Tipo>N3.1</Tipo>
			<Label>Totale non imponibile - esportazioni</Label>
		</Item>
		<Item>
			<Tipo>N3.2</Tipo>
			<Label>Totale non imponibile - cessioni intracomunitarie</Label>
		</Item>
		<Item>
			<Tipo>N3.3</Tipo>
			<Label>Totale non imponibile - cessioni verso San Marino</Label>
		</Item>
		<Item>
			<Tipo>N3.4</Tipo>
			<Label>Totale non imponibile - operazioni assimilate alle cessioni all'esportazione</Label>
		</Item>
		<Item>
			<Tipo>N3.5</Tipo>
			<Label>Totale non imponibile - a seguito di dichiarazioni d'intento</Label>
		</Item>
		<Item>
			<Tipo>N3.6</Tipo>
			<Label>Totale non imponibile - altre operazioni che non concorrono alla formazione del plafond</Label>
		</Item>
		<Item>
			<Tipo>N4</Tipo>
			<Label>Totale esente IVA</Label>
		</Item>
		<Item>
			<Tipo>N5</Tipo>
			<Label>Totale regime del margine/IVA non esposta</Label>
		</Item>
		<Item>
			<Tipo>N6</Tipo>
			<Label>Totale inversione contabile</Label>
		</Item>
		<Item>
			<Tipo>N6.1</Tipo>
			<Label>Totale inversione contabile - cessione di rottami e altri materiali di recupero</Label>
		</Item>
		<Item>
			<Tipo>N6.2</Tipo>
			<Label>Totale inversione contabile - cessione di oro e argento puro</Label>
		</Item>
		<Item>
			<Tipo>N6.3</Tipo>
			<Label>Totale inversione contabile - subappalto nel settore edile</Label>
		</Item>
		<Item>
			<Tipo>N6.4</Tipo>
			<Label>Totale inversione contabile - cessione di fabbricati</Label>
		</Item>
		<Item>
			<Tipo>N6.5</Tipo>
			<Label>Totale inversione contabile - cessione di telefoni cellulari</Label>
		</Item>
		<Item>
			<Tipo>N6.6</Tipo>
			<Label>Totale inversione contabile - cessione di prodotti elettronici</Label>
		</Item>
		<Item>
			<Tipo>N6.7</Tipo>
			<Label>Totale inversione contabile - prestazioni comparto edile e settori connessi</Label>
		</Item>
		<Item>
			<Tipo>N6.8</Tipo>
			<Label>Totale inversione contabile - operazioni settore energetico</Label>
		</Item>
		<Item>
			<Tipo>N6.9</Tipo>
			<Label>Totale inversione contabile - altri casi</Label>
		</Item>
		<Item>
			<Tipo>N7</Tipo>
			<Label>Totale IVA assolta in altro stato UE</Label>
		</Item>
	</xsl:variable>

	<xsl:template name="NomeFile">
		<xsl:param name="NomeAttachment"/>
		<xsl:param name="FormatoAttachment"/>

		<xsl:variable name="nomeFile" select="translate($NomeAttachment, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
		<xsl:variable name="extFile" select="concat('.', translate($FormatoAttachment, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'))" />

		<xsl:choose>
			<xsl:when test="(string-length($extFile) = 1) or ($extFile = substring($nomeFile, string-length($nomeFile) - string-length($extFile) + 1))">
				<xsl:value-of select="$nomeFile"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="concat($nomeFile, $extFile)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeNumeriDecimaliMax">
		<xsl:param name="nodeList"/>
		<xsl:param name="nomeCampo"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="numdec" select="string-length(substring-after($nodeList[1]/*[name() = $nomeCampo], '.'))"/>

				<xsl:choose>
					<xsl:when test="$numdec &gt; $totalSoFar">
						<xsl:call-template name="ComputeNumeriDecimaliMax">
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
							<xsl:with-param name="nomeCampo" select="$nomeCampo"/>
							<xsl:with-param name="totalSoFar" select="$numdec"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="ComputeNumeriDecimaliMax">
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
							<xsl:with-param name="nomeCampo" select="$nomeCampo"/>
							<xsl:with-param name="totalSoFar" select="$totalSoFar"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="$totalSoFar"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeFormatDecimalString">
		<xsl:param name="num"/>
		<xsl:param name="stringSoFar"/>
		<xsl:choose>
			<xsl:when test="$num &gt; 0">
				<xsl:variable name="format">0<xsl:value-of select="$stringSoFar"/></xsl:variable>

				<xsl:call-template name="ComputeFormatDecimalString">
					<xsl:with-param name="num" select="$num - 1"/>
					<xsl:with-param name="stringSoFar" select="$format"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:choose>
					<xsl:when test="string-length($stringSoFar) &gt; 0">0,<xsl:value-of select="$stringSoFar"/></xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeMaggiorazioneUnitario">
		<xsl:param name="importoUnitario"/>
		<xsl:param name="importoScMg"/>

		<xsl:variable name="perc" select="(($importoUnitario + $importoScMg) div $importoUnitario - 1) * 100" />
		<xsl:value-of select="format-number($perc, '0,00', 'euroFormat')" />%
	</xsl:template>

	<xsl:template name="ComputeScontoUnitario">
		<xsl:param name="importoUnitario"/>
		<xsl:param name="importoScMg"/>
		<xsl:param name="quantita"/>

		<xsl:variable name="perc" select="(1 -($importoUnitario - $importoScMg) div $importoUnitario) * 100" />
		<xsl:value-of select="format-number($perc, '0,00', 'euroFormat')" />%
	</xsl:template>

	<xsl:template name="ComputePrezzoTotale">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="importo" select="number($nodeList[1]/PrezzoTotale)"/>
				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputePrezzoTotale">
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="format-number($totalSoFar, '0.00')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeImportoRitenutaAcconto">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>

				<xsl:variable name="importo">
					<xsl:choose>
						<xsl:when test="$nodeList[1]/TipoRitenuta = 'RT01' or $nodeList[1]/TipoRitenuta = 'RT02'">
							<xsl:value-of select="number($nodeList[1]/ImportoRitenuta)"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputeImportoRitenutaAcconto">
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="format-number($totalSoFar, '0.00')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeImportoRitenutaPrevidenziale">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:param name="tipo"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="importo">
					<xsl:choose>
						<xsl:when test="$nodeList[1]/TipoRitenuta = $tipo">
							<xsl:value-of select="number($nodeList[1]/ImportoRitenuta)"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputeImportoRitenutaPrevidenziale">
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
					<xsl:with-param name="tipo" select="$tipo"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="format-number($totalSoFar, '0.00')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeNettoAPagare">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="importo" select="number($nodeList[1]/ImportoPagamento)"/>
				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputeNettoAPagare">
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="$totalSoFar"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeTotaleImposta">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="importo" select="number($nodeList[1]/Imposta)"/>
				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputeTotaleImposta">
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="$totalSoFar"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeTotaleImponibile">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="importo">
					<xsl:choose>
						<xsl:when test="$nodeList[1]/Imposta != 0">
							<xsl:copy-of select="number($nodeList[1]/ImponibileImporto)" />
						</xsl:when>
						<xsl:otherwise>
							0
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputeTotaleImponibile">
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="$totalSoFar"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeTotaleNatura">
		<xsl:param name="tipo"/>
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="importo">
					<xsl:choose>
						<xsl:when test="$nodeList[1]/AliquotaIVA = 0 and $nodeList[1]/Natura = $tipo">
							<xsl:copy-of select="number($nodeList[1]/ImponibileImporto)" />
						</xsl:when>
						<xsl:otherwise>
							0
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputeTotaleNatura">
					<xsl:with-param name="tipo" select="$tipo"/>
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="format-number($totalSoFar, '0.00')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ComputeScontiMaggiorazione">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:param name="formatOut"/>

		<xsl:if test="$nodeList">
			<!-- if there is still a node in the list -->
			<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>

			<xsl:variable name="Moltiplicatore">
				<xsl:choose>
					<xsl:when test="$nodeList[1]/Tipo = 'SC'">
						-1
					</xsl:when>
					<xsl:otherwise>
						1
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="Tipo">
				<xsl:copy-of select="$nodeList[1]/Tipo" />
			</xsl:variable>

			<xsl:variable name="importo">
				<xsl:choose>
					<xsl:when test="$nodeList[1]/Importo">
						<xsl:copy-of select="number($nodeList[1]/Importo)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="number($nodeList[1]/Percentuale) * $totalSoFar div 100" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="$Tipo = 'SC'">
							Sconto
						</xsl:when>
						<xsl:otherwise>
							Maggiorazione
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="$nodeList[1]/Percentuale">
						<xsl:value-of select="format-number($nodeList[1]/Percentuale, '0,00', 'euroFormat')"/>%
					</xsl:if>
				</td>
				<td style="text-align: right;">
					<xsl:value-of select="format-number($Moltiplicatore * $importo, $formatOut, 'euroFormat')"/>&#160;&#8364;
				</td>
			</tr>

			<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + ($Moltiplicatore * $importo)"/>
			<xsl:call-template name="ComputeScontiMaggiorazione">
				<xsl:with-param name="nodeList" select="$remainingNodes"/>
				<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				<xsl:with-param name="formatOut" select="$formatOut"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ComputeTotaleTrattenutaCassa">
		<xsl:param name="nodeList"/>
		<xsl:param name="totalSoFar"/>
		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>
				<xsl:variable name="importo">
					<xsl:choose>
						<xsl:when test="$nodeList[1]/TipoCassa != 'TC22'">
							<xsl:choose>
								<xsl:when test="$nodeList[1]/Ritenuta = 'SI'">
									<xsl:copy-of select="number($nodeList[1]/ImportoContributoCassa)" />
								</xsl:when>
								<xsl:otherwise>
									0
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							0
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="importoIncludingThisNode" select="$totalSoFar + $importo"/>
				<xsl:call-template name="ComputeTotaleTrattenutaCassa">
					<xsl:with-param name="nodeList" select="$remainingNodes"/>
					<xsl:with-param name="totalSoFar" select="$importoIncludingThisNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- return the computed value -->
				<xsl:value-of select="format-number($totalSoFar, '0.00')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="FormatDate">
		<xsl:param name="DateTime" />

		<xsl:variable name="year" select="substring($DateTime,1,4)" />
		<xsl:variable name="month" select="substring($DateTime,6,2)" />
		<xsl:variable name="day" select="substring($DateTime,9,2)" />

		<xsl:value-of select="$day" />
		<xsl:value-of select="'-'" />
		<xsl:value-of select="$month" />
		<xsl:value-of select="'-'" />
		<xsl:value-of select="$year" />

		<xsl:variable name="time" select="substring($DateTime,12)" />
		<xsl:if test="$time != ''">
			<xsl:variable name="hh" select="substring($time,1,2)" />
			<xsl:variable name="mm" select="substring($time,4,2)" />

			<xsl:value-of select="' '" />
			<xsl:value-of select="$hh" />
			<xsl:value-of select="':'" />
			<xsl:value-of select="$mm" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="FormatDateSmart">
		<xsl:param name="DateTime" />

		<xsl:variable name="year" select="substring($DateTime,1,4)" />
		<xsl:variable name="month" select="substring($DateTime,6,2)" />
		<xsl:variable name="day" select="substring($DateTime,9,2)" />

		<xsl:value-of select="$day" /><xsl:value-of select="'/'" /><xsl:value-of select="$month" /><xsl:value-of select="'/'" /><xsl:value-of select="$year" />
	</xsl:template>

	<xsl:template name="PrintSezioneRegimeFiscale">
		<xsl:param name="regime"/>
		<xsl:param name="nodeList"/>

		<xsl:choose>
			<xsl:when test="$regime">
					<xsl:variable name="block">
						<div class="block block-row">
							<div class="block-title">
								<svg height="14" width="14">
									<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
								</svg>
								<span>Regime fiscale</span>
							</div>
							<div class="block-body list-container">
								<xsl:value-of select="$regime" /> -
								<xsl:choose>
									<xsl:when test="$regime='RF01'">
										Regime ordinario
									</xsl:when>
									<xsl:when test="$regime='RF02'">
										Regime dei contribuenti minimi (art. 1,c.96-117, L. 244/2007)
									</xsl:when>
									<xsl:when test="$regime='RF04'">
										Agricoltura e attivit&#224; connesse e pesca (artt. 34 e 34-bis, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF05'">
										Vendita sali e tabacchi (art. 74, c.1, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF06'">
										Commercio dei fiammiferi (art. 74, c.1, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF07'">
										Editoria (art. 74, c.1, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF08'">
										Gestione di servizi di telefonia pubblica (art. 74, c.1, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF09'">
										Rivendita di documenti di trasporto pubblico e di sosta (art. 74, c.1, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF10'">
										Intrattenimenti, giochi e altre attivit&#224;	di cui alla tariffa allegata al D.P.R. 640/72 (art. 74, c.6, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF11'">
										Agenzie di viaggi e turismo (art. 74-ter, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF12'">
										Agriturismo (art. 5, c.2, L. 413/1991)
									</xsl:when>
									<xsl:when test="$regime='RF13'">
										Vendite a domicilio (art. 25-bis, c.6, D.P.R. 600/1973)
									</xsl:when>
									<xsl:when test="$regime='RF14'">
										Rivendita di beni usati, di oggetti	d'arte, d'antiquariato o da collezione (art. 36, D.L. 41/1995)
									</xsl:when>
									<xsl:when test="$regime='RF15'">
										Agenzie di vendite all'asta di oggetti d'arte, antiquariato o da collezione (art. 40-bis, D.L. 41/1995)
									</xsl:when>
									<xsl:when test="$regime='RF16'">
										IVA per cassa P.A. (art. 6, c.5, D.P.R. 633/1972)
									</xsl:when>
									<xsl:when test="$regime='RF17'">
										IVA per cassa (art. 32-bis, D.L. 83/2012)
									</xsl:when>
									<xsl:when test="$regime='RF18'">
										Altro
									</xsl:when>
									<xsl:when test="$regime='RF19'">
										Regime forfettario
									</xsl:when>
									<xsl:when test="$regime=''">
									</xsl:when>
									<xsl:otherwise>
										<span>(!!! codice non previsto !!!)</span>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</xsl:variable>
				<xsl:call-template name="PrintRitenuta">
					<xsl:with-param name="prevBlock" select="$block"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="numRitenuta" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList/DatiRitenuta"/>
					<xsl:with-param name="nodeListPrevidenziale" select="$nodeList/DatiCassaPrevidenziale"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintRitenuta">
					<xsl:with-param name="countBlock" select="0"/>
					<xsl:with-param name="numRitenuta" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList/DatiRitenuta"/>
					<xsl:with-param name="nodeListPrevidenziale" select="$nodeList/DatiCassaPrevidenziale"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintRitenuta">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="numRitenuta"/>
		<xsl:param name="nodeList"/>
		<xsl:param name="nodeListPrevidenziale"/>

		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>

				<xsl:variable name="block">
					<div class="block block-row">
						<div class="block-title">
							<svg height="14" width="14">
								<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
							</svg>
							<span>Ritenuta <xsl:value-of select="$numRitenuta" /></span>
						</div>
						<div class="block-body list-container">
							<xsl:if test="$nodeList/TipoRitenuta">
								<span class="list">
									<xsl:variable name="TR">
										<xsl:value-of select="$nodeList/TipoRitenuta" />
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$TR='RT01'">Ritenuta persone fisiche</xsl:when>
										<xsl:when test="$TR='RT02'">Ritenuta persone giuridiche</xsl:when>
										<xsl:when test="$TR='RT03'">Contributo INPS</xsl:when>
										<xsl:when test="$TR='RT04'">Contributo ENASARCO</xsl:when>
										<xsl:when test="$TR='RT05'">Contributo ENPAM</xsl:when>
										<xsl:when test="$TR='RT06'">Altro contributo previdenziale</xsl:when>
										<xsl:when test="$TR=''">
										</xsl:when>
										<xsl:otherwise>
											<span>(!!! codice non previsto !!!)</span>
										</xsl:otherwise>
									</xsl:choose></span>
							</xsl:if>
							<xsl:if test="$nodeList/AliquotaRitenuta">
								<span class="list">
									Aliquota ritenuta&#160;
									<xsl:value-of select="format-number($nodeList/AliquotaRitenuta, '0,00', 'euroFormat')"/>%
									su 100% dell'imponibile</span>
							</xsl:if>
							<xsl:if test="$nodeList/CausalePagamento">
								<span class="list">
									Causale pagamento&#160;
									<xsl:value-of select="$nodeList/CausalePagamento" />:&#160;
									<xsl:variable name="CP">
										<xsl:value-of select="$nodeList/CausalePagamento" />
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$CP='A'">
											Prestazioni di lavoro autonomo rientranti nell'esercizio di arte o professione abituale
										</xsl:when>
										<xsl:when test="$CP='B'">
											Utilizzazione economica, da parte dell'autore o dell'inventore, di opere dell'ingegno, di brevetti industriali e di processi, formule o informazioni relativi a esperienze acquisite in campo industriale, commerciale o scientifico
										</xsl:when>
										<xsl:when test="$CP='C'">
											Utili derivanti da contratti di associazione in partecipazione e da contratti di cointeressenza, quando l'apporto &#x000E8; costituito esclusivamente dalla prestazione di lavoro
										</xsl:when>
										<xsl:when test="$CP='D'">
											Utili spettanti ai soci promotori e ai soci fondatori delle societ&#224; di capitali
										</xsl:when>
										<xsl:when test="$CP='E'">
											Levata di protesti cambiari da parte dei segretari comunali
										</xsl:when>
										<xsl:when test="$CP='G'">
											Indennit&#224; corrisposte per la cessazione di attivit&#224; sportiva professionale
										</xsl:when>
										<xsl:when test="$CP='H'">
											Indennit&#224; corrisposte per la cessazione dei rapporti di agenzia delle persone fisiche e delle societ&#224; di persone, con esclusione delle somme maturate entro il 31.12.2003, gi&#224; imputate per competenza e tassate come reddito d'impresa
										</xsl:when>
										<xsl:when test="$CP='I'">
											Indennit&#224; corrisposte per la cessazione da funzioni notarili
										</xsl:when>
										<xsl:when test="$CP='L'">
											Utilizzazione economica, da parte di soggetto diverso dall'autore o dall'inventore, di opere dell'ingegno, di brevetti industriali e di processi, formule e informazioni relative a esperienze acquisite in campo industriale, commerciale o scientifico
										</xsl:when>
										<xsl:when test="$CP='L1'">
											Redditi derivanti dall'utilizzazione economica di opere dell'ingegno, di brevetti industriali e di processi, formule e
											informazioni relativi a esperienze acquisite in campo industriale, commerciale o scientifico, che sono percepiti da
											soggetti che abbiano acquistato a titolo oneroso i diritti alla loro utilizzazione
										</xsl:when>
										<xsl:when test="$CP='M'">
											Prestazioni di lavoro autonomo non esercitate abitualmente, obblighi di fare, di non fare o permettere
										</xsl:when>
										<xsl:when test="$CP='M1'">
											Redditi derivanti dall'assunzione di obblighi di fare, di non fare o permettere
										</xsl:when>
										<xsl:when test="$CP='M2'">
											Prestazioni di lavoro autonomo non esercitate abitualmente per le quali sussiste l'obbligo di iscrizione alla Gestione Separata ENPAPI
										</xsl:when>
										<xsl:when test="$CP='N'">
											Indennit&#224; di trasferta, rimborso forfetario di spese, premi e compensi erogati nell'esercizio diretto di attivit&#224; sportive dilettantistiche
										</xsl:when>
										<xsl:when test="$CP='O'">
											Prestazioni di lavoro autonomo non esercitate abitualmente, obblighi di fare, di non fare o permettere, per le quali non sussiste l'obbligo di iscrizione alla gestione separata (Circ. Inps 104/2001)
										</xsl:when>
										<xsl:when test="$CP='O1'">
											Redditi derivanti dall'assunzione di obblighi di fare, di non fare o permettere, per le quali non sussiste l'obbligo di iscrizione alla gestione separata (Circ. INPS n. 104/2001)
										</xsl:when>
										<xsl:when test="$CP='P'">
											Compensi corrisposti a soggetti non residenti privi di stabile organizzazione per l'uso o la concessione in uso di attrezzature industriali, commerciali o scientifiche che si trovano nel territorio dello
										</xsl:when>
										<xsl:when test="$CP='Q'">
											Provvigioni corrisposte ad agente o rappresentante di commercio monomandatario
										</xsl:when>
										<xsl:when test="$CP='R'">
											Provvigioni corrisposte ad agente o rappresentante di commercio plurimandatario
										</xsl:when>
										<xsl:when test="$CP='S'">
											Provvigioni corrisposte a commissionario
										</xsl:when>
										<xsl:when test="$CP='T'">
											Provvigioni corrisposte a mediatore
										</xsl:when>
										<xsl:when test="$CP='U'">
											Provvigioni corrisposte a procacciatore di affari
										</xsl:when>
										<xsl:when test="$CP='V'">
											Provvigioni corrisposte a incaricato per le vendite a domicilio e provvigioni corrisposte a incaricato per la vendita porta a porta e per la vendita ambulante di giornali quotidiani e periodici (L. 25.02.1987, n. 67)
										</xsl:when>
										<xsl:when test="$CP='V1'">
											Redditi derivanti da attivit&#224; commerciali non esercitate abitualmente (ad esempio, provvigioni corrisposte per prestazioni occasionali ad agente o rappresentante di commercio, mediatore, procacciatore d'affari)
										</xsl:when>
										<xsl:when test="$CP='V2'">
											Redditi derivanti dalle prestazioni non esercitate abitualmente rese dagli incaricati alla vendita diretta a domicilio
										</xsl:when>
										<xsl:when test="$CP='W'">
											Corrispettivi erogati nel 2013 per prestazioni relative a contratti d'appalto cui si sono resi applicabili le disposizioni contenute nell'art. 25-ter D.P.R. 600/1973
										</xsl:when>
										<xsl:when test="$CP='X'">
											Canoni corrisposti nel 2004 da societ&#224; o enti residenti, ovvero da stabili organizzazioni di societ&#224; estere di cui all'art. 26-quater, c. 1, lett. a) e b) D.P.R. 600/1973, a societ&#224; o stabili organizzazioni di societ&#224;, situate in altro Stato membro dell'Unione Europea in presenza dei relativi requisiti richiesti, per i quali &#x000E8; stato effettuato nel 2006 il rimborso della ritenuta ai sensi dell'art. 4 D. Lgs. 143/2005
										</xsl:when>
										<xsl:when test="$CP='Y'">
											Canoni corrisposti dal 1.01.2005 al 26.07.2005 da soggetti di cui al punto precedente
										</xsl:when>
										<xsl:when test="$CP='Z' or CP='ZO'">
											Titolo diverso dai precedenti
										</xsl:when>
										<xsl:when test="$CP=''">
										</xsl:when>
										<xsl:otherwise>
											<span>(!!! codice non previsto !!!)</span>
										</xsl:otherwise>
									</xsl:choose></span>
							</xsl:if>

						</div>
					</div>
				</xsl:variable>

				<xsl:variable name="nextCount" select="$countBlock + 1" />
				<xsl:choose>
					<xsl:when test="$nextCount mod 2 = 0">
						<xsl:if test="$nextCount > 0">
							<tr>
								<td class="no-padding">
									<xsl:copy-of select="$prevBlock" />
									<xsl:copy-of select="$block" />
								</td>
							</tr>
						</xsl:if>

						<xsl:call-template name="PrintRitenuta">
							<xsl:with-param name="countBlock" select="0"/>
							<xsl:with-param name="numRitenuta" select="$numRitenuta + 1"/>
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
							<xsl:with-param name="nodeListPrevidenziale" select="$nodeListPrevidenziale"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$countBlock = 1">
						<xsl:call-template name="PrintRitenuta">
							<xsl:with-param name="prevBlock" select="$prevBlock"/>
							<xsl:with-param name="countBlock" select="1"/>
							<xsl:with-param name="numRitenuta" select="$numRitenuta + 1"/>
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
							<xsl:with-param name="nodeListPrevidenziale" select="$nodeListPrevidenziale"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="PrintRitenuta">
							<xsl:with-param name="prevBlock" select="$block"/>
							<xsl:with-param name="countBlock" select="1"/>
							<xsl:with-param name="numRitenuta" select="$numRitenuta + 1"/>
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
							<xsl:with-param name="nodeListPrevidenziale" select="$nodeListPrevidenziale"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>

				<xsl:choose>
					<xsl:when test="$prevBlock">
						<xsl:call-template name="PrintCassaPrevidenziale">
							<xsl:with-param name="prevBlock" select="$prevBlock"/>
							<xsl:with-param name="numCassa" select="1"/>
							<xsl:with-param name="countBlock" select="1"/>
							<xsl:with-param name="nodeList" select="$nodeListPrevidenziale"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="PrintCassaPrevidenziale">
							<xsl:with-param name="numCassa" select="1"/>
							<xsl:with-param name="countBlock" select="0"/>
							<xsl:with-param name="nodeList" select="$nodeListPrevidenziale"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintCassaPrevidenziale">
		<xsl:param name="prevBlock"/>
		<xsl:param name="numCassa"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:choose>
			<xsl:when test="$nodeList">
				<!-- if there is still a node in the list -->
				<xsl:variable name="remainingNodes" select="$nodeList[position() != 1]"/>

				<xsl:variable name="block">
					<div class="block block-row">
						<div class="block-title">
							<svg height="14" width="14">
								<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
							</svg>
							<span>Cassa previdenziale&#160;<xsl:value-of select="$numCassa"/></span>
						</div>
						<div class="block-body list-container">
							<xsl:if test="$nodeList[1]/TipoCassa">
								<span class="list">
									<xsl:value-of select="$nodeList[1]/TipoCassa" />
									&#160;-&#160;
									<xsl:variable name="TC">
										<xsl:value-of select="$nodeList[1]/TipoCassa" />
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$TC='TC01'">
											Cassa nazionale previdenza e assistenza avvocati e procuratori legali </xsl:when>
										<xsl:when test="$TC='TC02'">
											Cassa previdenza dottori commercialisti</xsl:when>
										<xsl:when test="$TC='TC03'">
											Cassa previdenza e assistenza geometri</xsl:when>
										<xsl:when test="$TC='TC04'">
											Cassa nazionale previdenza e assistenza ingegneri e architetti liberi professionisti</xsl:when>
										<xsl:when test="$TC='TC05'">
											Cassa nazionale del notariato</xsl:when>
										<xsl:when test="$TC='TC06'">
											Cassa nazionale previdenza e assistenza ragionieri e periti commerciali</xsl:when>
										<xsl:when test="$TC='TC07'">
											Ente nazionale assistenza agenti e rappresentanti di commercio (ENASARCO)</xsl:when>
										<xsl:when test="$TC='TC08'">
											Ente nazionale previdenza e assistenza consulenti del lavoro (ENPACL)</xsl:when>
										<xsl:when test="$TC='TC09'">
											Ente nazionale previdenza e assistenza medici (ENPAM)</xsl:when>
										<xsl:when test="$TC='TC10'">
											Ente nazionale previdenza e assistenza farmacisti (ENPAF)</xsl:when>
										<xsl:when test="$TC='TC11'">
											Ente nazionale previdenza e assistenza veterinari (ENPAV)</xsl:when>
										<xsl:when test="$TC='TC12'">
											Ente nazionale previdenza e assistenza impiegati dell'agricoltura (ENPAIA)</xsl:when>
										<xsl:when test="$TC='TC13'">
											Fondo previdenza impiegati imprese di spedizione e agenzie marittime</xsl:when>
										<xsl:when test="$TC='TC14'">
											Istituto nazionale previdenza giornalisti italiani (INPGI)</xsl:when>
										<xsl:when test="$TC='TC15'">
											Opera nazionale assistenza orfani sanitari italiani (ONAOSI)</xsl:when>
										<xsl:when test="$TC='TC16'">
											Cassa autonoma assistenza integrativa giornalisti italiani (CASAGIT)</xsl:when>
										<xsl:when test="$TC='TC17'">
											Ente previdenza periti industriali e periti industriali laureati (EPPI)</xsl:when>
										<xsl:when test="$TC='TC18'">
											Ente previdenza e assistenza pluricategoriale (EPAP)</xsl:when>
										<xsl:when test="$TC='TC19'">
											Ente nazionale previdenza e assistenza biologi (ENPAB)</xsl:when>
										<xsl:when test="$TC='TC20'">
											Ente nazionale previdenza e assistenza professione infermieristica (ENPAPI)</xsl:when>
										<xsl:when test="$TC='TC21'">
											Ente nazionale previdenza e assistenza psicologi (ENPAP)</xsl:when>
										<xsl:when test="$TC='TC22'">
											INPS</xsl:when>
										<xsl:when test="$TC=''"></xsl:when>
										<xsl:otherwise>
											<span>(!!! codice non previsto !!!)</span>&#160;
										</xsl:otherwise>
									</xsl:choose></span>
							</xsl:if>
							<xsl:if test="$nodeList[1]/ImponibileCassa">
								<span class="list">
									Imponibile cassa:
									<xsl:value-of select="format-number($nodeList[1]/ImponibileCassa, '0,00', 'euroFormat')"/>&#160;&#8364;</span>
							</xsl:if>
							<xsl:if test="$nodeList[1]/AlCassa">
								<span class="list">
									Aliquota cassa:
									<xsl:value-of select="format-number($nodeList[1]/AlCassa, '0,00', 'euroFormat')"/>%</span>
							</xsl:if>
							<xsl:if test="$nodeList[1]/AliquotaIVA">
								<span class="list">
									IVA
									<xsl:value-of select="format-number($nodeList[1]/AliquotaIVA, '0,00', 'euroFormat')"/>%
									<xsl:if test="$nodeList[1]/Natura">
										&#160;-&#160;
										<span>
											<xsl:value-of select="$nodeList[1]/Natura"/>
										</span>
									</xsl:if></span>
							</xsl:if>
							<xsl:if test="$nodeList[1]/Ritenuta">
								<xsl:variable name="RT">
									<xsl:value-of select="$nodeList[1]/Ritenuta" />
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$RT='SI'">
										<span class="list">
											contributo cassa soggetta a ritenuta</span>
									</xsl:when>
									<xsl:otherwise>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="$nodeList[1]/RiferimentoAmministrazione">
								<span class="list">
									Rif. amministrazione:&#160;
									<xsl:value-of select="$nodeList[1]/RiferimentoAmministrazione"/></span>
							</xsl:if>
						</div>
					</div>
				</xsl:variable>

				<xsl:variable name="nextCount" select="$countBlock + 1" />
				<xsl:choose>
					<xsl:when test="$nextCount mod 2 = 0">
						<xsl:if test="$nextCount > 0">
							<tr>
								<td class="no-padding">
									<xsl:copy-of select="$prevBlock" />
									<xsl:copy-of select="$block" />
								</td>
							</tr>
						</xsl:if>

						<xsl:call-template name="PrintCassaPrevidenziale">
							<xsl:with-param name="numCassa" select="$numCassa + 1"/>
							<xsl:with-param name="countBlock" select="0"/>
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$countBlock = 1">
						<xsl:call-template name="PrintCassaPrevidenziale">
							<xsl:with-param name="prevBlock" select="$prevBlock"/>
							<xsl:with-param name="numCassa" select="$numCassa + 1"/>
							<xsl:with-param name="countBlock" select="1"/>
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="PrintCassaPrevidenziale">
							<xsl:with-param name="prevBlock" select="$block"/>
							<xsl:with-param name="numCassa" select="$numCassa + 1"/>
							<xsl:with-param name="countBlock" select="1"/>
							<xsl:with-param name="nodeList" select="$remainingNodes"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$countBlock mod 2 = 1">
				<tr>
					<td class="no-padding">
						<xsl:copy-of select="$prevBlock" />
					</td>
				</tr>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintSezionePostDocumentiCorrelati">
		<xsl:param name="nodeList"/>

			<xsl:variable name="block">
				<xsl:if test="$nodeList/Allegati">
					<div class="block block-row">
						<div class="block-title">
							<svg height="14" width="14">
								<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
							</svg>
							<span>Allegati</span>
						</div>
						<div class="block-body">
							<table class="eTable small normal" style="margin-bottom: 0">
								<thead class="eTableHeadGrey">
									<tr>
										<th style="width: 50%;">Nome allegato</th>
										<th style="width: 50%;">Descrizione</th>
									</tr>
								</thead>
								<tbody>
									<xsl:for-each select="$nodeList/Allegati">
										<tr class="eTableRow">
											<td>
												<div class="truncate">
													<xsl:variable name="id" select="position()"/>
													<xsl:variable name="content" select="Attachment"/>

													<xsl:variable name="nome">
														<xsl:call-template name="NomeFile">
															<xsl:with-param name="NomeAttachment" select="NomeAttachment" />
															<xsl:with-param name="FormatoAttachment" select="FormatoAttachment" />
														</xsl:call-template>
													</xsl:variable>

													<a id="allegato{$id}" class="link" data-content="{$content}" href="data:octet-stream;base64,{$content}" download="{$nome}">
														<xsl:value-of select="$nome"/>
													</a>
												</div>
											</td>
											<td>
												<div class="truncate">
													<xsl:if test="DescrizioneAttachment">
														<xsl:value-of select="DescrizioneAttachment"/>
													</xsl:if>
												</div>
											</td>
										</tr>
										<tr class="eTableSubRow"><td colspan="2" class="no-padding"></td></tr>
									</xsl:for-each>
								</tbody>
							</table>
						</div>
					</div>
				</xsl:if>
			</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/Allegati">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="PrintDatiBollo">
			<xsl:with-param name="prevBlock" select="$block"/>
			<xsl:with-param name="countBlock" select="number($blockPresent)"/>
			<xsl:with-param name="nodeList" select="$nodeList"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="PrintDatiBollo">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:variable name="block">
			<xsl:if test="$nodeList/DatiGenerali/DatiGeneraliDocumento/DatiBollo">
				<div class="block block-row">
					<div class="block-title">
						<svg height="14" width="14">
							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
						</svg>
						<span>Dati bollo</span>
					</div>
					<div class="block-body">
						<xsl:if test="$nodeList/DatiGenerali/DatiGeneraliDocumento/DatiBollo/ImportoBollo">
							Importo
							<xsl:value-of select="format-number($nodeList/DatiGenerali/DatiGeneraliDocumento/DatiBollo/ImportoBollo, '0,00', 'euroFormat')" />&#160;&#8364;
						</xsl:if>
						<xsl:if test="$nodeList/DatiGenerali/DatiGeneraliDocumento/DatiBollo/BolloVirtuale and $nodeList/DatiGenerali/DatiGeneraliDocumento/DatiBollo/BolloVirtuale = 'SI'">
							<xsl:if test="$nodeList/DatiGenerali/DatiGeneraliDocumento/DatiBollo/ImportoBollo">&#160;-&#160;</xsl:if>Imposta di bollo assolta in modo virtuale ai sensi dell'articolo 15 del d.p.r. 642/1972 e del DM 17/06/2014
						</xsl:if>
					</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/DatiGenerali/DatiGeneraliDocumento/DatiBollo">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="nextCount" select="$countBlock + number($blockPresent)" />
		<xsl:choose>
			<xsl:when test="$nextCount mod 2 = 0">
				<xsl:if test="$nextCount > 0">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
							<xsl:copy-of select="$block" />
						</td>
					</tr>
				</xsl:if>

				<xsl:call-template name="PrintCausale">
					<xsl:with-param name="countBlock" select="0"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$countBlock = 1">
				<xsl:call-template name="PrintCausale">
					<xsl:with-param name="prevBlock" select="$prevBlock"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintCausale">
					<xsl:with-param name="prevBlock" select="$block"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintCausale">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:variable name="block">
			<xsl:if test="$nodeList/DatiGenerali/DatiGeneraliDocumento/Causale">
				<div class="block block-row">
					<div class="block-title">
						<svg height="14" width="14">
							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
						</svg>
						<span>Causale documento</span>
					</div>
					<div class="block-body">
					Descrizione causale:
						<xsl:for-each select="$nodeList/DatiGenerali/DatiGeneraliDocumento/Causale">
							<xsl:variable name="caus" select="." />
							<xsl:value-of select="$caus"/>&#160;
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/DatiGenerali/DatiGeneraliDocumento/Causale">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="nextCount" select="$countBlock + number($blockPresent)" />
		<xsl:choose>
			<xsl:when test="$nextCount mod 2 = 0">
				<xsl:if test="$nextCount > 0">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
							<xsl:copy-of select="$block" />
						</td>
					</tr>
				</xsl:if>

				<xsl:call-template name="PrintArt73">
					<xsl:with-param name="countBlock" select="0"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$countBlock = 1">
				<xsl:call-template name="PrintArt73">
					<xsl:with-param name="prevBlock" select="$prevBlock"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintArt73">
					<xsl:with-param name="prevBlock" select="$block"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintArt73">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:variable name="block">
			<xsl:if test="$nodeList/DatiGenerali/DatiGeneraliDocumento/Art73 and $nodeList/DatiGenerali/DatiGeneraliDocumento/Art73 = 'SI'">
				<div class="block block-row">
					<div class="block-title">
						<svg height="14" width="14">
							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
						</svg>
						<span>ART.73 DPR 633/72</span>
					</div>
					<div class="block-body">
					Fattura &#x000E8; emessa secondo modalit&#224; e termini stabiliti con decreto ministeriale ai sensi dell'articolo 73 del DPR 633/72
					</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/DatiGenerali/DatiGeneraliDocumento/Art73 and $nodeList/DatiGenerali/DatiGeneraliDocumento/Art73 = 'SI'">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="nextCount" select="$countBlock + number($blockPresent)" />
		<xsl:choose>
			<xsl:when test="$nextCount mod 2 = 0">
				<xsl:if test="$nextCount > 0">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
							<xsl:copy-of select="$block" />
						</td>
					</tr>
				</xsl:if>

				<xsl:call-template name="PrintFatturaPrincipale">
					<xsl:with-param name="countBlock" select="0"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$countBlock = 1">
				<xsl:call-template name="PrintFatturaPrincipale">
					<xsl:with-param name="prevBlock" select="$prevBlock"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintFatturaPrincipale">
					<xsl:with-param name="prevBlock" select="$block"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintFatturaPrincipale">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:variable name="block">
			<xsl:if test="$nodeList/DatiGenerali/FatturaPrincipale">
				<div class="block block-row">
					<div class="block-title">
						<svg height="14" width="14">
							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
						</svg>
						<span>Fattura principale</span>
					</div>
					<div class="block-body">
						Numero
						<xsl:value-of select="$nodeList/DatiGenerali/FatturaPrincipale/NumeroFatturaPrincipale" />&#160;del:&#160;
						<xsl:call-template name="FormatDateSmart">
							<xsl:with-param name="DateTime" select="$nodeList/DatiGenerali/FatturaPrincipale/DataFatturaPrincipale" />
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/DatiGenerali/FatturaPrincipale">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="nextCount" select="$countBlock + number($blockPresent)" />
		<xsl:choose>
			<xsl:when test="$nextCount mod 2 = 0">
				<xsl:if test="$nextCount > 0">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
							<xsl:copy-of select="$block" />
						</td>
					</tr>
				</xsl:if>

				<xsl:call-template name="PrintDatiSAL">
					<xsl:with-param name="countBlock" select="0"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$countBlock = 1">
				<xsl:call-template name="PrintDatiSAL">
					<xsl:with-param name="prevBlock" select="$prevBlock"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintDatiSAL">
					<xsl:with-param name="prevBlock" select="$block"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintDatiSAL">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:variable name="block">
			<xsl:if test="$nodeList/DatiGenerali/DatiSAL">
				<div class="block block-row">
					<div class="block-title">
						<svg height="14" width="14">
							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
						</svg>
						<span>Dati SAL</span>
					</div>
					<div class="block-body">
						Riferimento fase: <xsl:value-of select="$nodeList/DatiGenerali/DatiSAL/RiferimentoFase" />
					</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/DatiGenerali/DatiSAL">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="nextCount" select="$countBlock + number($blockPresent)" />
		<xsl:choose>
			<xsl:when test="$nextCount mod 2 = 0">
				<xsl:if test="$nextCount > 0">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
							<xsl:copy-of select="$block" />
						</td>
					</tr>
				</xsl:if>

				<xsl:call-template name="PrintDatiVeicoli">
					<xsl:with-param name="countBlock" select="0"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$countBlock = 1">
				<xsl:call-template name="PrintDatiVeicoli">
					<xsl:with-param name="prevBlock" select="$prevBlock"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintDatiVeicoli">
					<xsl:with-param name="prevBlock" select="$block"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="PrintDatiVeicoli">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:variable name="block">
			<xsl:if test="$nodeList/DatiVeicoli">
				<div class="block block-row">
					<div class="block-title">
						<svg height="14" width="14">
							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
						</svg>
						<span>Dati veicolo</span>
					</div>
					<div class="block-body">
						<xsl:for-each select="$nodeList/DatiVeicoli">
							<div class="list-container">
								<xsl:if test="TotalePercorso">
									<span class="list">
										Totale percorso: <xsl:value-of select="TotalePercorso" />&#160;km
									</span>
								</xsl:if>
								<xsl:if test="Data">
									immatricolazione:
									<xsl:call-template name="FormatDateSmart">
										<xsl:with-param name="DateTime" select="Data" />
									</xsl:call-template>
								</xsl:if>
							</div>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/DatiVeicoli">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="nextCount" select="$countBlock + number($blockPresent)" />
		<xsl:choose>
			<xsl:when test="$nextCount mod 2 = 0">
				<xsl:if test="$nextCount > 0">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
							<xsl:copy-of select="$block" />
						</td>
					</tr>
				</xsl:if>

				<xsl:call-template name="PrintDatiTrasporto">
					<xsl:with-param name="countBlock" select="0"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$countBlock = 1">
				<xsl:call-template name="PrintDatiTrasporto">
					<xsl:with-param name="prevBlock" select="$prevBlock"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintDatiTrasporto">
					<xsl:with-param name="prevBlock" select="$block"/>
					<xsl:with-param name="countBlock" select="1"/>
					<xsl:with-param name="nodeList" select="$nodeList"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="PrintDatiTrasporto">
		<xsl:param name="prevBlock"/>
		<xsl:param name="countBlock"/>
		<xsl:param name="nodeList"/>

		<xsl:variable name="block">
			<xsl:if test="$nodeList/DatiGenerali/DatiTrasporto">
				<div class="block block-row">
					<div class="block-title">
						<svg height="14" width="14">
							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
						</svg>
						<span>Dati Trasporto</span>
					</div>
					<div class="block-body">
						<xsl:if test="$nodeList/DatiGenerali/DatiTrasporto/DatiAnagraficiVettore">
							<div class="sub-block">
								<div class="sub-block-title">Dati anagrafici vettore</div>
								<div class="sub-block-body">
									<xsl:for-each select="$nodeList/DatiGenerali/DatiTrasporto/DatiAnagraficiVettore">
										<div class="list-container">
											<xsl:choose>
												<xsl:when test="Anagrafica/Denominazione">
													<span class="list">
														<xsl:value-of select="Anagrafica/Denominazione" />
													</span>
												</xsl:when>
												<xsl:otherwise>
													<span class="list">
														<xsl:if test="Anagrafica/Nome">
															<xsl:value-of select="Anagrafica/Nome" />&#160;
														</xsl:if>
														<xsl:if test="Anagrafica/Cognome">
															<xsl:value-of select="Anagrafica/Cognome" />
														</xsl:if>
													</span>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:if test="IdFiscaleIVA">
												P.IVA:
												<span class="list">
													<xsl:value-of select="IdFiscaleIVA/IdPaese" />
													<xsl:value-of select="IdFiscaleIVA/IdCodice" />
												</span>
											</xsl:if>
											<xsl:if test="CodiceFiscale">
												C.F.:
												<span class="list">
													<xsl:value-of select="CodiceFiscale" />
												</span>

											</xsl:if>
											<xsl:if test="NumeroLicenzaGuida">
												Numero licenza di guida:
												<span class="list">
													<xsl:value-of select="NumeroLicenzaGuida" />
												</span>
											</xsl:if>
										</div>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>

						<xsl:if test="$nodeList/DatiGenerali/DatiTrasporto/MezzoTrasporto or $nodeList/DatiGenerali/DatiTrasporto/CausaleTrasporto or $nodeList/DatiGenerali/DatiTrasporto/NumeroColli or $nodeList/DatiGenerali/DatiTrasporto/Descrizione or $nodeList/DatiGenerali/DatiTrasporto/UnitaMisuraPeso or $nodeList/DatiGenerali/DatiTrasporto/PesoLordo or $nodeList/DatiGenerali/DatiTrasporto/PesoNetto or $nodeList/DatiGenerali/DatiTrasporto/DataOraRitiro or $nodeList/DatiGenerali/DatiTrasporto/DataInizioTrasporto or $nodeList/DatiGenerali/DatiTrasporto/DataOraConsegna">
							<div class="sub-block">
								<div class="sub-block-title">Informazioni trasporto</div>
								<div class="sub-block-body">
									<xsl:for-each select="$nodeList/DatiGenerali/DatiTrasporto">
										<div class="list-container">
											<xsl:if test="MezzoTrasporto">
												Mezzo di trasporto:
												<span class="list">
													<xsl:value-of select="MezzoTrasporto" />
												</span>
											</xsl:if>
											<xsl:if test="CausaleTrasporto">
												Causale trasporto:
												<span class="list">
													<xsl:value-of select="CausaleTrasporto" />
												</span>
											</xsl:if>
											<xsl:if test="NumeroColli">
												Numero colli trasportati:
												<span class="list">
													<xsl:value-of select="NumeroColli" />
												</span>
											</xsl:if>
											<xsl:if test="Descrizione">
												Descrizione:
												<span class="list">
													<xsl:value-of select="Descrizione" />
												</span>
											</xsl:if>
											<xsl:if test="UnitaMisuraPeso">
												Unit&#224; misura peso:
												<span class="list">
													<xsl:value-of select="UnitaMisuraPeso" />
												</span>
											</xsl:if>
											<xsl:if test="PesoLordo">
												Peso lordo:
												<span class="list">
													<xsl:value-of select="format-number(PesoLordo, '0,00', 'euroFormat')" />
												</span>
											</xsl:if>
											<xsl:if test="PesoNetto">
												Peso netto:
												<span class="list">
													<xsl:value-of select="format-number(PesoNetto, '0,00', 'euroFormat')" />
												</span>
											</xsl:if>
											<xsl:if test="DataOraRitiro">
												Data e ora ritiro:
												<span class="list">
													<xsl:call-template name="FormatDate">
														<xsl:with-param name="DateTime" select="DataOraRitiro" />
													</xsl:call-template>
												</span>
											</xsl:if>
											<xsl:if test="DataInizioTrasporto">
												Data inizio trasporto:
												<span class="list">
													<xsl:call-template name="FormatDate">
														<xsl:with-param name="DateTime" select="DataInizioTrasporto" />
													</xsl:call-template>
												</span>
											</xsl:if>
											<xsl:if test="DataOraConsegna">
												Data ora consegna:
												<span class="list">
													<xsl:call-template name="FormatDate">
														<xsl:with-param name="DateTime" select="DataOraConsegna" />
													</xsl:call-template>
												</span>
											</xsl:if>
										</div>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>

						<xsl:if test="$nodeList/DatiGenerali/DatiTrasporto/TipoResa or $nodeList/DatiGenerali/DatiTrasporto/IndirizzoResa">
							<div class="sub-block">
								<div class="sub-block-title">Informazioni resa</div>
								<div class="sub-block-body">
									<xsl:for-each select="$nodeList/DatiGenerali/DatiTrasporto">
										<div class="list-container">
											<xsl:if test="TipoResa">
												Tipo resa:
												<span class="list">
													<xsl:value-of select="TipoResa" />
												</span>
											</xsl:if>
											<span class="list">
												<xsl:if test="IndirizzoResa/Indirizzo">
													<xsl:value-of select="IndirizzoResa/Indirizzo" />
												</xsl:if>
												<xsl:if test="IndirizzoResa/NumeroCivico">, <xsl:value-of select="IndirizzoResa/NumeroCivico" />
												</xsl:if>
												<xsl:if test="IndirizzoResa/CAP">
													-&#160;<xsl:value-of select="IndirizzoResa/CAP" />
												</xsl:if>
												<xsl:if test="IndirizzoResa/Comune">
													-&#160;<xsl:value-of select="IndirizzoResa/Comune" />
												</xsl:if>
												<xsl:if test="IndirizzoResa/Provincia">
													(<xsl:value-of select="IndirizzoResa/Provincia" />)
												</xsl:if>
												<xsl:if test="IndirizzoResa/Nazione">
													-&#160;<xsl:value-of select="IndirizzoResa/Nazione" />
												</xsl:if>
											</span>
										</div>
									</xsl:for-each>
								</div>
							</div>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="blockPresent">
			<xsl:choose>
				<xsl:when test="$nodeList/DatiGenerali/DatiTrasporto">
					1
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="nextCount" select="$countBlock + number($blockPresent)" />
		<xsl:choose>
			<xsl:when test="$nextCount mod 2 = 0">
				<xsl:if test="$nextCount > 0">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
							<xsl:copy-of select="$block" />
						</td>
					</tr>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$countBlock = 1">
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$prevBlock" />
						</td>
					</tr>
			</xsl:when>
			<xsl:otherwise>
					<tr>
						<td class="no-padding">
							<xsl:copy-of select="$block" />
						</td>
					</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/">
<!--
		<xsl:text disable-output-escaping='yes'>&lt;!doctype html&gt;</xsl:text>
-->
		<html>
			<head>
				<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
				<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
				<link href="https://fonts.googleapis.com/css?family=Lato:700" rel="stylesheet" />

<style type="text/css" media="print,screen">
/*! normalize.css v8.0.1 | MIT License | github.com/necolas/normalize.css */html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}main{display:block}h1{font-size:2em;margin:.67em 0}hr{box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace,monospace;font-size:1em}a{background-color:transparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:bolder}code,kbd,samp{font-family:monospace,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:1px dotted ButtonText}fieldset{padding:.35em .75em .625em}legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}progress{vertical-align:baseline}textarea{overflow:auto}[type=checkbox],[type=radio]{box-sizing:border-box;padding:0}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details{display:block}summary{display:list-item}template{display:none}[hidden]{display:none}
</style>

<style type="text/css" media="print,screen">
.text-right {
	text-align: right;
}
body {
	font-family: Arial;
	font-size: 12px;
	margin: 0;
}
.no-padding { padding: 0; }

.only-mobile-inline,
.only-mobile {
	display: none;
}

td.only-desktop {
	display: table-cell;
}

.header-fattura .dati {
	margin-bottom: 3px;
	word-break: break-all;
	line-height: 20px;
}

.titolo {
	font-family: Lato, Arial;
	text-transform: uppercase;
	font-weight: bold;
	text-align: left;
	margin-bottom: 10px;
}

.numeroDocumento {
	font-weight: bold;
	margin-bottom: 15px;
	font-size: 12px;
}

.flex-row {
	display: flex;
	flex-direction: row;
}
.flex-cell {
	/*width: 50%;*/
	flex-basis: 0;
	flex-grow: 1;
	max-width: 100%;

	line-height: 19px;
	font-size: 14px;
	word-break: break-all;
	padding: 0cm;
}
.flex-cell > .flex-container {
	padding: 0.35cm;
}
.flex-row .titolo {
	font-size: 20px;
}
.flex-row .blocco-fattura {
	text-align: right;
	font-size: 12px;
}
.flex-row .blocco-fattura .flex-container {
	padding-right: 0;
	padding-bottom: 0.1cm;
}
.flex-row .blocco-fattura .titolo {
	font-size: 22px;
	text-align: right;
}
.flex-row .blocco-fattura .dati-generali {
	font-size: 14px;
}

.flex-row .blocco-fornitore .flex-container {
	padding-left: 0;
}

.flex-row .flex-row .flex-cell:last-child {
	padding-left: 0.5cm;
	padding-right: 0;
}

.flex-row .flex-row .flex-cell:first-child,
.flex-row .flex-row .flex-cell {
	padding: 0;
}

.flex-row .blocco-cliente {
	background-color: #F3F3F3;
}

.list-container {
	display: inline-block;
}
.list-container span.list:after {
	content: ", ";
}
.list-container span.list:last-child:after {
	content: " ";
}

th {
	text-align: left;
	vertical-align: middle;
	background-color: #D6D6D6;
	padding: 1% 0.3%;
	font-size: 12px;
	text-transform: uppercase;
}
.noUpperCase th {
	text-transform: none;
}
.small th {
	padding: 0.5%;
}
td {
	vertical-align: top;
}
.eTableRow td {
	padding: 1% 0.3% 0;
	font-size: 13px;
}
.eTableRow td .valore {
	font-weight: bold;
}
.normal .eTableRow td .valore {
	font-weight: normal;
}
.eTableSubRow td {
	font-size: 11px;
	padding: 0.3%;
	border-bottom: 1px solid #ddd;
}

.quantita {
	width: 40px;
}

.fattura td {
	padding: 4px 0;
	font-size: 14px;
}

.fattura tfoot th {
	font-size: 21px;
}

th.importo, td.importo { text-align: right; }
th.center, td.center { text-align: center; }

td.importo-right .valore {
	text-align: right;
	display: inline-block;
	width: 100%;

}

.truncate {
	width: 100%;
	overflow: hidden;
	word-break: break-all;
}

.link {
	text-decoration: underline;
	color: #035791;
	cursor: pointer;
}

.sectionHeader {
	font-family: Lato, Arial;
	text-transform: uppercase;
	font-weight: bold;
	font-size: 20px;
	padding-top: 7px;
	padding-bottom: 12px;
	text-align: center;
	background-color: #fff;
}

.hline {
	border-top: 1px solid #ddd;
	margin-top: 10px;
	margin-bottom: 10px;
}

table {
	width: 100%;
	border-collapse: collapse;
	margin-bottom: 5px;
}
thead {
	display: table-header-group;
}
tfoot {
	display: table-footer-group;
}

table.tableDesktop {
	margin-bottom: 5px;
}
table.tableDesktop td .chiave {
	display: none;
}

.blockContainer {
	padding: 0;
	margin: 0;
}
.block {
	width: 49.3%;
	padding-right: 0.2%;
	padding-top: 5px;
	padding-bottom: 1px;
	display: inline-block;
	vertical-align: top;
}
.block .block-title {
	font-size: 14px;
	text-transform: uppercase;
	margin-bottom: 4px;
	display: flex;
	align-items: center;
}
.block .block-title > svg {
	margin-right: 5px;
}
.block .block-title .list-item {
	height: 12px;
	width: 12px;
}
.block .block-body {
	padding-left: 19px;
	padding-right: 10px;
	font-size: 14px;
	line-height: 21px;
}

.block.block-100 {
	width: 100%;
	display: block;
	padding-right: 0px;
}
.block.block-100 .block-body {
	padding-right: 0px;
	padding-left: 18px;
}

.block .sub-block {
	padding-bottom: 7px;
}
.block .sub-block .sub-block-title {
	text-transform: uppercase;
}
.block.fattura {
	padding-left: 1%;
	width: 48%;
}

#footer, .report-footer td {
	height: 65px;
}

#footer {
	width: 100%;
	font-size: 9px;
	position: fixed;
	bottom: 0px;
	left: 0px;
}
.report-container {
	margin-bottom: 0;
}
.report-footer .numeroFattura {
	text-align: left;
	width: 49%;
	padding-left: 10px;
}
.report-footer .data {
	border-top: 1px solid #ccc;
	margin-top: 5px;
	padding-top: 5px;
	position: relative
}
.report-footer .loghi {
	display: flex;
	flex-direction: column;
	margin-top: -10px;
}
.report-footer .loghi .immagini {
	display: flex;
	flex-direction: row;
	justify-content: center;
}
.report-footer .loghi .immagini div {
	width: 110px;
}
.report-footer .loghi img{
	vertical-align: middle;
}
.report-footer .loghi .logoAruba {
	padding-left: 13px;
	text-align: left;
}
.report-footer .loghi .logoArubaPEC {
	margin-top: 2px;
	padding-right: 12px;
	border-right: 2px solid #eee;
}
.report-footer .loghi .logoArubaPEC svg {
	width: 95px;
	height: 22px;
}
.report-footer .loghi .logoAruba svg {
	width: 70px;
	height: 18px;
}
.report-footer .footer-info {
	font-family: 'Lato';
	font-size: 8px;
	padding-top: 5px;
	padding-bottom: 5px;
}
.report-footer .loghi .disclaimer {
	padding-bottom: 2px;
}

</style>

<style type="text/css" media="print">
	@page {
		size: A4 portrait;
		margin: 0.5cm 0.5cm 0.3cm;
	}
	th {
		font-size: 10px;
	}
	.flex-row .titolo {
		font-size: 18px;
	}
	.flex-row .blocco-fattura .titolo {
		font-size: 20px;
	}
	.flex-row .blocco-fattura .dati-generali {
		font-size: 12px;
	}
	.flex-cell {
		line-height: 17px;
	}
	.flex-cell > .flex-container {
		padding: 0.2cm;
	}
	.flex-row .flex-row .flex-cell:last-child {
		padding-left: 0.25cm;
	}
	.flex-cell .blocco-fornitore .flex-container {
		padding-right: 0;
	}

	.sectionHeader {
		page-break-after: avoid;
		page-break-before: auto;

		font-size: 16px;
		padding-top: 5px;
		padding-bottom: 10px;
	}

	.flex-cell {
		font-size: 11px;
	}
	.eTableRow th {
		padding: 0.9% 0.2%;
	}
	.eTableRow td {
		padding: 0.5% 0.2%;
		font-size: 11px;
	}
	.block .block-title {
		font-size: 12px;
	}
	.block .block-title > svg {
		margin-right: 5px;
	}
	.block .block-body {
		padding-left: 19px;
		padding-right: 1.5%;
		font-size: 12px;
		line-height: 15px;
	}
	.block.block-100 .block-body {
		padding-left: 19px;
	}
	.report-footer-space td {
		height: 90px;
	}
	.report-footer.in-table {
		display: none;
	}
	.report-footer.out-table {
		display: block;
	}
	.report-footer {
		position: fixed;
		bottom: 0;

		width: 100%;
		height: 67px;
		padding-top: 2px;
	}
	.block.fattura {
		padding-left: 2%;
		width: 47.5%;
	}
	.report-footer .invisible {
		visibility: hidden;
	}
	td.break-inside {
		page-bread-inside: auto;
	}
	.fattura td {
		padding: 2px 0;
		font-size: 12px;
	}
	.fattura tfoot th {
		font-size: 18px;
	}

	.safari .report-container {
		position: relative;
		width: 100%;
	}
	.safari .report-footer.in-table {
		display: block;
		width: 100%;
	}
	.safari .report-footer.out-table {
		display: none;
	}
	.safari .report-footer {
		position: absolute;
		bottom: 0;
		left: 0;
	}

</style>

<style type="text/css" media="screen">

#fattura-container {
	max-width: 1024px;
	margin: 0 auto;
}

.containers {
/*
	box-shadow: 0 0 10px #ccc;
*/
	margin-top: 0.25cm;
	margin-bottom: 0.25cm;
	width: 100%;
}

.main {
	padding: 0.5cm 0.5cm 0;
}

.report-footer .footer-info {
	font-family: 'Lato';
	font-size: 9px;
	padding-top: 10px;
	padding-bottom: 15px;
}

.report-footer.out-table {
	display: none;
}
.report-footer.in-table {
	display: block;
}

.report-footer .loghi .disclaimer {
	padding-bottom: 5px;
}

/* iPhone XR: 1792x828px at 326ppi */
@media ((device-width : 414px)
	and (device-height : 896px)
	and (-webkit-device-pixel-ratio : 2) and (orientation : portrait) ),

/* iPhone XS: 2436x1125px at 458ppi */
	((device-width : 375px)
	and (device-height : 812px)
	and (-webkit-device-pixel-ratio : 3) and (orientation : portrait) ),

/* iPhone XS Max: 2688x1242px at 458ppi */
	((device-width : 414px)
	and (device-height : 896px)
	and (-webkit-device-pixel-ratio : 3) and (orientation : portrait) ),

(max-width: 480px) {
	#fattura-container {
		max-width: 100%;
		margin: 0 auto;
	}

	.containers {
		box-shadow: none;
	}

	.numeroDocumento {
		border-top: 1px solid #ccc;
	}

	.main {
		padding: 0.5cm 0.2cm 0;
	}

	.flex-row {
		display: block;
	}
	.flex-cell {
		width: 100%;
	}
	.flex-row .blocco-fattura {
		text-align: left;
		padding-left: 0;
	}
	.flex-row .blocco-fattura .flex-container {
		padding-top: 0;
		padding-bottom: 0;
		padding-left: 0;
	}
	.flex-row .blocco-fattura .titolo {
		text-align: left;
	}
	.flex-row .flex-row .flex-cell:last-child {
		padding-left: 0cm;
	}
	.flex-row .blocco-fornitore .flex-container {
		padding-top: 32px;
	}

	.header-fattura .dati {
		display: block;
		font-size: 13px;
		margin-bottom: 25px;
	}

	.sectionHeader {
		text-align: center;
		font-size: 20px;
	}

	th {
		font-size: 10px;
	}
	td {
		padding: 6px;
		font-size: 13px;
	}
	.eTableRow td {
		padding: 5px 0;
	}
	.quantita {
		width: auto;
	}

	table.tableDesktop > thead {
		display: none;
	}

	.only-mobile {
		display: block!important;
	}

	.only-mobile-inline {
		display: inline-block!important;
	}

	td.only-desktop {
		display: none!important;
	}

	table.tableDesktop > tbody > tr > td {
		display: block;
		border-bottom: 1px solid #ccc;
	}
	table.tableDesktop > tbody > tr > td.hide {
		display: none;
	}
	table.tableDesktop > tbody > tr > td:first-child {
		padding-top: 10px;
	}

	table.tableDesktop > tbody > tr.eTableSubRow > td {
		display: block;
		border-bottom: 0;
		font-size: 11px;
	}

	table.tableDesktop > tbody > tr.eTableRow > td.center {
		text-align: left;
	}

	table.tableDesktop > tbody > tr.eTableSubRow > td:first-child {
		padding:0;
	}
	table.tableDesktop > tbody > tr.eTableSubRow > td:last-child:not(.no-padding) {
		display: block;
		padding-top: 15px;
		padding-bottom: 30px;
		border-bottom: 2px solid #666;
	}
	table.tableDesktop > tbody > tr.eTableSubRow:last-child > td:last-child {
		border-bottom: 1px solid #ddd;
	}

	table.tableDesktop td .chiave {
		display: inline-block;
		width: 35%;
		padding-right: 1%;
		text-transform: uppercase;
		font-weight: normal;
		vertical-align: top;
		font-size: 12px;
	}
	table.tableDesktop.noUpperCase td .chiave {
		text-transform: none;
	}
	table.tableDesktop td .valore {
		display: inline-block;
		width: 62%;
		font-weight: bold;
		vertical-align: top;
		font-size: 14px;
		text-align: right;
	}
	th.importo, td.importo { text-align: left; }

	table.tableDesktop > tbody > tr.eTableSubRow > td.low-padding:last-child {
		padding: 15px;
	}
	.block .block-title {
		font-size: 14px;
	}

	.block.fattura,
	.block {
		width: 100%;
		padding-top: 15px;
		padding-right: 0;
		padding-left: 0;
	}
	.fattura td {
		border-bottom: 1px solid #ddd;
	}

	.report-footer .data {
		border-top: 0;
		display: flex;
		flex-direction: column-reverse;
		padding-top: 30px;
	}
	.report-footer .numeroFattura {
		text-align: center;
		width: 100%;
		padding-top: 10px;
		padding-bottom: 10px;
		padding-left: 0;
	}
	.report-footer .loghi {
		text-align: center;
		width: 100%;
	}
	.report-footer .loghi .logoArubaPEC img {
		padding-left: 0px;
	}
	.report-footer .loghi .logoArubaPEC {
		width: 45%;
		text-align: right;
	}
	.report-footer .loghi .logoAruba {
		width: 45%;
		text-align: left;
	}
}

@media (max-width: 320.5px) {
	table.tableDesktop td .valore {
		font-size: 13px;
	}
	table.tableDesktop td .chiave {
		width: 34%;
	}
	.report-footer .loghi .logoArubaPEC svg {
		width: 120px;
	}
	.report-footer .loghi .logoAruba svg {
		width: 90px;
	}
}
</style>
				<script type="text/javascript">

				<![CDATA[

function checkBrowser() {
	var isIE = /*@cc_on!@*/false || !!document.documentMode;
	// Edge 20+
	var isEdge = !isIE && !!window.StyleMedia;

	var ua = navigator.userAgent.toLowerCase();
	if (ua.indexOf('safari') != -1 || ua.indexOf('applewebkit') != -1) {
		if (ua.indexOf('chrome') > -1) {

		} else {
			document.body.classList.add('safari');
		}
	}

	if (isIE || isEdge) {
		var links = document.querySelectorAll('.link');
		[].forEach.call(links, function(link) {

			link.addEventListener('click', function(event) {
				var tgt = event.currentTarget;
				//https://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers/417184#417184
				download(tgt.dataset.content, tgt.innerHTML);
			}, false);
		});
	}
}

function download(base64Data, filename) {
	var arrBuffer = base64ToArrayBuffer(base64Data);

	// It is necessary to create a new blob object with mime-type explicitly set
	// otherwise only Chrome works like it should
	var newBlob = new Blob([arrBuffer], { type: "application/pdf" });

	// IE doesn't allow using a blob object directly as link href
	// instead it is necessary to use msSaveOrOpenBlob
	if (window.navigator && window.navigator.msSaveOrOpenBlob) {
		window.navigator.msSaveOrOpenBlob(newBlob, filename);
		return;
	}

	// For other browsers:
	// Create a link pointing to the ObjectURL containing the blob.
	var data = window.URL.createObjectURL(newBlob);

	var link = document.createElement('a');
	document.body.appendChild(link); //required in FF, optional for Chrome
	link.href = data;
	link.download = filename;
	link.click();
	window.URL.revokeObjectURL(data);
	link.remove();
}

function base64ToArrayBuffer(data) {
	var binaryString = window.atob(data);
	var binaryLen = binaryString.length;
	var bytes = new Uint8Array(binaryLen);
	for (var i = 0; i < binaryLen; i++) {
		var ascii = binaryString.charCodeAt(i);
		bytes[i] = ascii;
	}
	return bytes;
}


				]]>
				</script>
			</head>
			<body onload="checkBrowser()">
				<div id="fattura-container">
					<!--INIZIO DATI HEADER-->
					<xsl:if test="a:FatturaElettronica">
							<xsl:variable name="soggettoEmittente">
								<xsl:choose>
									<xsl:when test="a:FatturaElettronica/FatturaElettronicaHeader/SoggettoEmittente">
										1
									</xsl:when>
									<xsl:otherwise>
										0
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<!--INIZIO DATI BODY-->

							<xsl:variable name="TOTALBODY">
								<xsl:value-of select="count(a:FatturaElettronica/FatturaElettronicaBody)" />
							</xsl:variable>

							<xsl:variable name="NEWLINE">
								<xsl:text>&#xa;</xsl:text>
							</xsl:variable>

							<xsl:variable name="RegimeFiscale">
								<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/RegimeFiscale">
									<xsl:value-of select="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici/RegimeFiscale" />
								</xsl:if>
							</xsl:variable>

							<xsl:variable name="DATI_CEDENTE_PRESTATORE">
								<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore">
									<div class="flex-row">
										<div class="flex-cell">
											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici">
												<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/DatiAnagrafici">
													<div>
														<b>
															<xsl:choose>
																<xsl:when test="Anagrafica/Denominazione">
																	<xsl:value-of select="Anagrafica/Denominazione" />
																</xsl:when>
																<xsl:otherwise>
																	<xsl:if test="Anagrafica/Nome">
																		<xsl:value-of select="Anagrafica/Nome" />&#160;
																	</xsl:if>
																	<xsl:if test="Anagrafica/Cognome">
																		<xsl:value-of select="Anagrafica/Cognome" />
																	</xsl:if>
																</xsl:otherwise>
															</xsl:choose>
														</b>
													</div>
													<xsl:if test="IdFiscaleIVA">
														<div>
															P.IVA:
															<xsl:value-of select="IdFiscaleIVA/IdPaese" />
															<xsl:value-of select="IdFiscaleIVA/IdCodice" />
														</div>
													</xsl:if>
													<xsl:if test="CodiceFiscale">
														<div>
															C.F.:
															<xsl:value-of select="CodiceFiscale" />
														</div>
													</xsl:if>
												</xsl:for-each>
											</xsl:if>

											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede">
												<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Sede">
													<div>
														<xsl:if test="Indirizzo">
															<xsl:value-of select="Indirizzo" />
														</xsl:if>
														<xsl:if test="NumeroCivico">, <xsl:value-of select="NumeroCivico" />
														</xsl:if>
													</div>
													<div>
														<xsl:if test="CAP">
															<xsl:value-of select="CAP" />&#160;-
														</xsl:if>
														<xsl:if test="Comune">
															<xsl:value-of select="Comune" />
														</xsl:if>
														<xsl:if test="Provincia">
															(<span><xsl:value-of select="Provincia" /></span>)
														</xsl:if>
														<xsl:if test="Nazione">
															-&#160;<xsl:value-of select="Nazione" />
														</xsl:if>
													</div>
												</xsl:for-each>
											</xsl:if>

											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Contatti">
												<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/Contatti">
													<xsl:if test="Telefono or Fax or Email">
														<xsl:if test="Telefono">
															<div>
																Telefono:
																<xsl:value-of select="Telefono" />
															</div>
														</xsl:if>
														<xsl:if test="Fax">
															<div>
																Fax:
																<xsl:value-of select="Fax" />
															</div>
														</xsl:if>
														<xsl:if test="Email">
															<div>
																<xsl:value-of select="Email" />
															</div>
														</xsl:if>
													</xsl:if>
												</xsl:for-each>
											</xsl:if>
										</div>

										<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/StabileOrganizzazione or a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/RappresentanteFiscale">
										<div class="flex-cell">
											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/StabileOrganizzazione">
												<div class="subHeader">STABILE ORGANIZZAZIONE</div>
												<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CedentePrestatore/StabileOrganizzazione">
													<div>
														<xsl:if test="Indirizzo">
															<xsl:value-of select="Indirizzo" />
														</xsl:if>
														<xsl:if test="NumeroCivico">, <xsl:value-of select="NumeroCivico" />
														</xsl:if>
													</div>
													<div>
														<xsl:if test="CAP">
															<xsl:value-of select="CAP" />&#160;-
														</xsl:if>
														<xsl:if test="Comune">
															<xsl:value-of select="Comune" />
														</xsl:if>
														<xsl:if test="Provincia">
														(<span><xsl:value-of select="Provincia" /></span>)
														</xsl:if>
														<xsl:if test="Nazione">
															-&#160;<xsl:value-of select="Nazione" />
														</xsl:if>
													</div>
												</xsl:for-each>
												<br/>
											</xsl:if>

											<!--INIZIO DATI RAPPRESENTANTE FISCALE-->
											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/RappresentanteFiscale">
												<div id="rappresentante-fiscale">
													<div class="subHeader">RAPPRESENTANTE FISCALE</div>

													<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/RappresentanteFiscale">
														<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/RappresentanteFiscale/DatiAnagrafici">
															<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/RappresentanteFiscale/DatiAnagrafici">
																<xsl:choose>
																	<xsl:when test="Anagrafica/Denominazione">
																		<span>
																			<xsl:value-of select="Anagrafica/Denominazione" />
																		</span>
																	</xsl:when>
																	<xsl:otherwise>
																		<span>
																			<xsl:if test="Anagrafica/Nome">
																				<xsl:value-of select="Anagrafica/Nome" />&#160;
																			</xsl:if>
																			<xsl:if test="Anagrafica/Cognome">
																				<xsl:value-of select="Anagrafica/Cognome" />
																			</xsl:if>
																		</span>
																	</xsl:otherwise>
																</xsl:choose>
																<xsl:if test="IdFiscaleIVA">
																	<br/>
																	P.IVA:
																	<span>
																		<xsl:value-of select="IdFiscaleIVA/IdPaese" />
																		<xsl:value-of select="IdFiscaleIVA/IdCodice" />
																	</span>
																</xsl:if>
																<xsl:if test="CodiceFiscale">
																	<br/>
																	C.F.:
																	<span>
																		<xsl:value-of select="CodiceFiscale" />
																	</span>

																</xsl:if>
															</xsl:for-each>
														</xsl:if>
													</xsl:if>

												</div>
											</xsl:if>
											<!--FINE DATI RAPPRESENTANTE FISCALE-->
										</div>
										</xsl:if>
									</div>
								</xsl:if>

							</xsl:variable>

							<xsl:variable name="DATI_TERZO_INTERMEDIARIO_O_SOGGETTO_EMITTENTE">
									<!--INIZIO DATI TERZO INTERMEDIARIO SOGGETTO EMITTENTE-->
									<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/TerzoIntermediarioOSoggettoEmittente">
										<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici">
											<div class="terzointermediario list-container">
												<span class="list">
													<xsl:choose>
														<xsl:when test="Anagrafica/Denominazione">
															<xsl:value-of select="Anagrafica/Denominazione" />
														</xsl:when>
														<xsl:otherwise>
															<xsl:if test="Anagrafica/Nome">
																<xsl:value-of select="Anagrafica/Nome" />&#160;
															</xsl:if>
															<xsl:if test="Anagrafica/Cognome">
																<xsl:value-of select="Anagrafica/Cognome" />
															</xsl:if>
														</xsl:otherwise>
													</xsl:choose>
												</span>
												<xsl:if test="IdFiscaleIVA">
													<span class="list">
													P.IVA:
														<xsl:value-of select="IdFiscaleIVA/IdPaese" />
														<xsl:value-of select="IdFiscaleIVA/IdCodice" />
													</span>
												</xsl:if>
												<xsl:if test="CodiceFiscale">
													<span class="list">
													C.F.:
														<xsl:value-of select="CodiceFiscale" />
													</span>

												</xsl:if>
											</div>
										</xsl:for-each>
									</xsl:if>
									<!--FINE DATI TERZO INTERMEDIARIO SOGGETTO EMITTENTE-->
							</xsl:variable>

							<xsl:variable name="DATI_SOGGETTO_EMITTENTE">
								<!--INIZIO DATI SOGGETTO EMITTENTE-->
								<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/SoggettoEmittente">
									<div id="soggetto-emittente">
										<span>emesso da:</span>

										<xsl:variable name="SC">
											<xsl:value-of select="a:FatturaElettronica/FatturaElettronicaHeader/SoggettoEmittente" />
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="$SC='CC'">
												cessionario/committente
											</xsl:when>
											<xsl:when test="$SC='TZ'">
												soggetto terzo
											</xsl:when>
											<xsl:when test="$SC=''">
											</xsl:when>
											<xsl:otherwise>
												<span>(!!! codice non previsto !!!)</span>
											</xsl:otherwise>
										</xsl:choose>
									</div>
								</xsl:if>
								<!--FINE DATI SOGGETTO EMITTENTE-->
							</xsl:variable>


							<xsl:variable name="DATI_CESSIONARIO_COMMITTENTE">
								<div class="flex-row">
									<div class="flex-cell">
										<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente">
											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/DatiAnagrafici">
												<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/DatiAnagrafici">
													<div>
														<b>
															<xsl:choose>
																<xsl:when test="Anagrafica/Denominazione">
																	<xsl:value-of select="Anagrafica/Denominazione" />
																</xsl:when>
																<xsl:otherwise>
																	<xsl:if test="Anagrafica/Nome">
																		<xsl:value-of select="Anagrafica/Nome" />&#160;
																	</xsl:if>
																	<xsl:if test="Anagrafica/Cognome">
																		<xsl:value-of select="Anagrafica/Cognome" />
																	</xsl:if>
																</xsl:otherwise>
															</xsl:choose>
														</b>
													</div>
													<xsl:if test="IdFiscaleIVA">
														<div>
															P.IVA:
															<xsl:value-of select="IdFiscaleIVA/IdPaese" />
															<xsl:value-of select="IdFiscaleIVA/IdCodice" />
														</div>
													</xsl:if>
													<xsl:if test="CodiceFiscale">
														<div>
															C.F.:
															<xsl:value-of select="CodiceFiscale" />
														</div>
													</xsl:if>
												</xsl:for-each>
											</xsl:if>

											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/Sede">
												<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/Sede">
													<div>
														<xsl:if test="Indirizzo">
															<xsl:value-of select="Indirizzo" />
														</xsl:if>
														<xsl:if test="NumeroCivico">, <xsl:value-of select="NumeroCivico" />
														</xsl:if>
													</div>
													<div>
														<xsl:if test="CAP">
															<xsl:value-of select="CAP" />&#160;-
														</xsl:if>
														<xsl:if test="Comune">
															<xsl:value-of select="Comune" />
														</xsl:if>
														<xsl:if test="Provincia">
															(<span><xsl:value-of select="Provincia" /></span>)
														</xsl:if>
														<xsl:if test="Nazione">
															&#160;-&#160;<xsl:value-of select="Nazione" />
														</xsl:if>
													</div>
												</xsl:for-each>
											</xsl:if>

											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/Contatti">
												<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/Contatti">
													<xsl:if test="Telefono or Fax or Email">
														<xsl:if test="Telefono">
															<div>
																Telefono:
																<xsl:value-of select="Telefono" />
															</div>
														</xsl:if>
														<xsl:if test="Fax">
															<div>
																Fax:
																<xsl:value-of select="Fax" />
															</div>
														</xsl:if>
														<xsl:if test="Email">
															<div>
																<xsl:value-of select="Email" />
															</div>
														</xsl:if>
													</xsl:if>
												</xsl:for-each>
											</xsl:if>

											<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/CodiceDestinatario">
												<div>
													Codice destinatario:
													<xsl:value-of select="a:FatturaElettronica/FatturaElettronicaHeader/DatiTrasmissione/CodiceDestinatario" />
												</div>
											</xsl:if>
										</xsl:if>
									</div>
									<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/StabileOrganizzazione or a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/RappresentanteFiscale">
									<div class="flex-cell">
										<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/StabileOrganizzazione">
											<div class="subHeader">STABILE ORGANIZZAZIONE</div>
											<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/StabileOrganizzazione">
												<div>
													<xsl:if test="Indirizzo">
														<xsl:value-of select="Indirizzo" />
													</xsl:if>
													<xsl:if test="NumeroCivico">, <xsl:value-of select="NumeroCivico" />
													</xsl:if>
												</div>
												<div>
													<xsl:if test="CAP">
														<xsl:value-of select="CAP" />&#160;-
													</xsl:if>
													<xsl:if test="Comune">
														<xsl:value-of select="Comune" />
													</xsl:if>
													<xsl:if test="Provincia">
														(<span><xsl:value-of select="Provincia" /></span>)
													</xsl:if>
													<xsl:if test="Nazione">
														-&#160;<xsl:value-of select="Nazione" />
													</xsl:if>
												</div>
											</xsl:for-each>
											<br/>
										</xsl:if>

										<!--INIZIO DATI RAPPRESENTANTE FISCALE-->
										<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/RappresentanteFiscale">
											<div id="rappresentante-fiscale">
												<div class="subHeader">RAPPRESENTANTE FISCALE</div>

												<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/RappresentanteFiscale">
													<xsl:if test="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/RappresentanteFiscale/DatiAnagrafici">
														<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaHeader/CessionarioCommittente/RappresentanteFiscale/DatiAnagrafici">
															<xsl:choose>
																<xsl:when test="Anagrafica/Denominazione">
																	<span>
																		<xsl:value-of select="Anagrafica/Denominazione" />
																	</span>
																</xsl:when>
																<xsl:otherwise>
																	<span>
																		<xsl:if test="Anagrafica/Nome">
																			<xsl:value-of select="Anagrafica/Nome" />&#160;
																		</xsl:if>
																		<xsl:if test="Anagrafica/Cognome">
																			<xsl:value-of select="Anagrafica/Cognome" />
																		</xsl:if>
																	</span>
																</xsl:otherwise>
															</xsl:choose>
															<xsl:if test="IdFiscaleIVA">
																<br/>
																P.IVA:
																<span>
																	<xsl:value-of select="IdFiscaleIVA/IdPaese" />
																	<xsl:value-of select="IdFiscaleIVA/IdCodice" />
																</span>
															</xsl:if>
															<xsl:if test="CodiceFiscale">
																<br/>
																C.F.:
																<span>
																	<xsl:value-of select="CodiceFiscale" />
																</span>

															</xsl:if>
														</xsl:for-each>
													</xsl:if>
												</xsl:if>

											</div>
											</xsl:if>
										<!--FINE DATI RAPPRESENTANTE FISCALE-->
									</div>
									</xsl:if>
								</div>
							</xsl:variable>


							<xsl:for-each select="a:FatturaElettronica/FatturaElettronicaBody">
								<xsl:variable name="Page_Break">
									<xsl:if test="position() > 1">
										page-break-before:always;
									</xsl:if>
								</xsl:variable>

								<xsl:variable name="PAGE_FOOTER">
									<xsl:variable name="numeroClass">
										<xsl:choose>
											<xsl:when test="$TOTALBODY = 1"> </xsl:when>
											<xsl:otherwise> invisible </xsl:otherwise>
										</xsl:choose>
									</xsl:variable>

									<div class="footer-info" style="text-align: center">
										<div class="info">
											Copia analogica della fattura elettronica inviata a SdI | Il documento XML originale &#x000E8; disponibile online sul portale "Fatture e Corrispettivi" dell'Agenzia delle Entrate.
										</div>
										<div class="data">

											<div class="numeroFattura {$numeroClass}">
												Fattura Nr. <xsl:value-of select="DatiGenerali/DatiGeneraliDocumento/Numero" /> del
												<span>
													<xsl:call-template name="FormatDateSmart">
														<xsl:with-param name="DateTime" select="DatiGenerali/DatiGeneraliDocumento/Data" />
													</xsl:call-template>
												</span>
											</div>
											<div class="loghi">
												<div class="disclaimer">Fattura visualizzata con foglio di stile di</div>
												<div class="immagini">
													<div class="logoArubaPEC">
														<svg
														xmlns:dc="http://purl.org/dc/elements/1.1/"
														xmlns:cc="http://creativecommons.org/ns#"
														xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
														xmlns:svg="http://www.w3.org/2000/svg"
														xmlns="http://www.w3.org/2000/svg"
														xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
														xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
														version="1.1"
														id="Livello_1"
														x="0px"
														y="0px"
														viewBox="0 0 446.77654 98.247754"
														xml:space="preserve"
														sodipodi:docname="Logo pec.svg"
														width="446.77655"
														height="98.247757"
														inkscape:version="0.92.3 (2405546, 2018-03-11)"><metadata
														id="metadata153"><rdf:RDF><cc:Work
															rdf:about=""><dc:format>image/svg+xml</dc:format><dc:type
																rdf:resource="http://purl.org/dc/dcmitype/StillImage" /></cc:Work></rdf:RDF></metadata><defs
														id="defs151" /><sodipodi:namedview
														pagecolor="#ffffff"
														bordercolor="#666666"
														borderopacity="1"
														objecttolerance="10"
														gridtolerance="10"
														guidetolerance="10"
														inkscape:pageopacity="0"
														inkscape:pageshadow="2"
														inkscape:window-width="1920"
														inkscape:window-height="1051"
														id="namedview149"
														showgrid="false"
														inkscape:zoom="0.88337851"
														inkscape:cx="203.56624"
														inkscape:cy="49.28978"
														inkscape:window-x="-9"
														inkscape:window-y="-9"
														inkscape:window-maximized="1"
														inkscape:current-layer="Livello_1" />
															<style
															type="text/css"
															id="style2">
																.st0{display:none;}
																.st1{display:inline;}
																.st2{fill:#E35205;}
																.st3{fill:#FFFFFF;}
																.st4{fill:#E73D33;}
																.st5{fill:#AF1A19;}
																.st6{fill:#979391;}
																.st7{fill:#A01A19;}
															</style>
															<g
															id="logo_trasparente_con_bordo"
															class="st0"
															style="display:none"
															transform="translate(-34.723458,-61.842024)">
																<g
															class="st1"
															id="g54"
															style="display:inline">
																	<g
															id="g8">
																		<g
															id="g6">
																			<path
															class="st2"
															d="m 91.7,94.9 c 1.5,0 2.7,0.9 3.4,2.4 0.6,1.3 1,3.8 1.3,7.6 0.3,3.6 0.5,10.6 0.6,20.8 0.1,10.2 0.3,17.2 0.4,20.9 0.1,3.9 0.1,6.4 -0.2,7.8 -0.5,2.7 -2.1,3.1 -3,3.1 -0.9,0 -2.3,-0.4 -3.3,-2.4 -0.4,-0.8 -0.8,-2.5 -0.9,-8.8 l -4.3,4.7 c -1.6,1.8 -3.5,3.2 -5.6,4.3 -2.1,1.1 -4.1,1.8 -6,1.9 -0.5,0 -0.9,0.1 -1.5,0.1 -1.5,0 -3.3,-0.1 -5.4,-0.4 -2.7,-0.4 -4.8,-0.7 -6.4,-1 C 59,155.6 57,154.7 54.5,153 52,151.4 50.2,149.7 49.1,148 L 46,143.4 c -1.2,-1.7 -1.8,-3.9 -2,-6.3 -0.1,-2.2 -0.1,-4.5 0,-6.7 0.1,-2.2 0.3,-4.6 0.6,-7.2 0.3,-2.7 0.8,-5.1 1.6,-7.1 0.8,-1.9 1.6,-4 2.5,-6.3 1,-2.6 2.2,-4.4 3.5,-5.4 1.3,-1 2.7,-1.8 4.4,-2.5 1.6,-0.7 3.5,-1.4 5.6,-2.1 2,-0.7 4,-1.1 5.8,-1.1 0.3,0 0.6,0 0.9,0 2,0.1 4.6,0.6 7.7,1.4 3.2,0.8 5.7,1.7 7.6,2.6 1.2,0.6 2.4,1.4 3.3,2.3 -0.1,-1.2 -0.2,-2.2 -0.3,-3.1 -0.1,-1.6 0,-3.1 0.5,-4.3 0.6,-1.5 1.8,-2.5 3.3,-2.7 0.4,0 0.5,0 0.7,0 m -20.6,54.2 c 1.1,0 2.1,-0.2 3.2,-0.5 2,-0.6 3.8,-1.5 5.4,-2.8 1.6,-1.3 3.2,-3.1 4.6,-5.4 1.4,-2.3 2.5,-4.6 3.1,-6.9 0.6,-2.3 0.8,-4.6 0.7,-7 -0.1,-2.4 -0.8,-5 -2,-7.7 -1.5,-3.5 -2.4,-5 -2.9,-5.6 -0.7,-0.9 -1.7,-2 -3.1,-3.2 -1.2,-1.1 -2.5,-1.7 -4,-1.9 -1.7,-0.2 -3.4,-0.4 -5,-0.4 h -4.8 c -1.5,0 -2.3,0.3 -2.6,0.5 -0.8,0.5 -2.1,1.2 -3.9,2 -3.2,2.6 -5.4,5.4 -6.4,8.4 -1.1,3.1 -1.6,6.7 -1.6,10.4 0,3.9 0.1,6.9 0.4,9 0.2,1.7 0.8,2.9 1.7,3.5 1.3,0.9 2.6,1.9 3.9,2.9 1.1,0.9 2.7,1.7 4.6,2.5 2,0.7 4,1.4 6.1,1.9 0.9,0.2 1.8,0.3 2.6,0.3 M 91.7,86.9 c -0.5,0 -1,0 -1.4,0.1 -3.9,0.5 -7.2,2.7 -9,6.1 -0.8,-0.2 -1.6,-0.4 -2.5,-0.7 -3.6,-0.9 -6.6,-1.4 -9.1,-1.6 -0.5,0 -1,0 -1.5,0 -2.7,0 -5.6,0.5 -8.5,1.5 -2.3,0.8 -4.3,1.6 -6,2.3 -2.3,1 -4.4,2.2 -6.2,3.6 -2.6,2 -4.5,4.9 -6.1,8.8 -0.9,2.3 -1.7,4.3 -2.5,6.2 -1.1,2.7 -1.8,5.9 -2.2,9.3 -0.3,2.7 -0.5,5.2 -0.6,7.5 -0.2,2.5 -0.2,5.1 0,7.6 0.2,3.9 1.3,7.3 3.3,10.3 l 3.1,4.6 c 1.7,2.6 4.3,5 7.6,7.2 3.5,2.3 6.5,3.7 9.5,4.2 1.6,0.3 3.8,0.6 6.5,1 2.5,0.4 4.6,0.5 6.5,0.5 0.7,0 1.4,0 2.1,-0.1 3,-0.2 6,-1.2 9.1,-2.8 0.6,-0.3 1.1,-0.6 1.7,-1 2.2,2.6 5.2,4 8.6,4 4.1,0 9.4,-2.5 10.8,-9.6 0.4,-2.1 0.5,-5 0.4,-9.7 -0.1,-3.6 -0.3,-10.6 -0.4,-20.7 -0.1,-10.4 -0.3,-17.5 -0.6,-21.3 -0.4,-5 -0.9,-8 -1.9,-10.3 -2,-4.3 -6.1,-7 -10.7,-7 z m -24.8,28.8 h 4.3 c 1.1,0 2.4,0.1 3.6,0.3 1.2,1.1 1.8,1.8 2,2 0.1,0.2 0.7,1.1 2,4.1 0.8,1.8 1.3,3.5 1.3,4.9 0.1,1.6 -0.1,3.1 -0.5,4.6 -0.4,1.5 -1.1,3 -2.1,4.6 -1.2,1.9 -2.2,2.9 -2.8,3.4 -0.8,0.6 -1.8,1.1 -2.8,1.4 -0.3,0.1 -0.6,0.1 -0.9,0.1 -0.2,0 -0.5,0 -0.7,-0.1 -1.8,-0.4 -3.5,-0.9 -5.2,-1.6 -1.5,-0.6 -2.2,-1 -2.4,-1.2 -0.9,-0.7 -1.8,-1.4 -2.7,-2.1 -0.1,-1.4 -0.2,-3.6 -0.2,-7.2 0,-2.9 0.4,-5.5 1.2,-7.8 0.5,-1.3 1.5,-2.7 3.1,-4.1 1.2,-0.5 2.1,-0.9 2.8,-1.3 z m -6.7,21.5 v 0 z"
															id="path4"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g14">
																		<g
															id="g12">
																			<path
															class="st2"
															d="m 116.3,97.1 c 1.2,0 2.5,0.4 3.1,1.5 0.8,1.7 0.7,4.1 0.9,4.8 0.3,-0.3 0.6,-0.7 1,-1.1 1.7,-1.9 4,-3.2 6.9,-3.9 2.2,-0.6 4.5,-0.8 6.8,-0.8 0.4,0 0.9,0 1.3,0 2.6,0.1 5,0.5 7,1 2.2,0.6 4.2,1.7 5.9,3.1 1.4,1.2 2.6,2.1 3.5,2.6 1.4,0.9 2.2,2 2.4,3.4 0.2,1.3 -0.1,2.5 -0.9,3.5 -1,1.3 -2.1,1.5 -2.9,1.5 -1,0 -2,-0.4 -3.2,-1.2 -0.9,-0.6 -1.6,-1.1 -2.2,-1.5 -0.7,-0.4 -1.8,-1.3 -3.3,-2.7 -1.2,-1.1 -2.6,-1.8 -4.3,-2.1 -0.7,-0.1 -1.5,-0.2 -2.3,-0.2 -1.2,0 -2.4,0.1 -3.8,0.4 -2.3,0.5 -4.3,1.3 -5.9,2.6 -1.6,1.3 -3,2.8 -4.1,4.4 -0.8,1.3 -1.1,1.9 -1.3,2.1 0.1,1.2 0.2,3.8 0.2,10.5 0,6.9 0.1,13.6 0.2,19.7 0.2,9.2 -0.5,10.8 -1.1,11.5 -0.7,0.9 -1.6,1.3 -2.5,1.3 -0.5,0 -0.9,-0.1 -1.4,-0.3 -1.3,-0.6 -2,-2.2 -2.2,-4.7 C 114,150.6 113.3,135 112,104 v -1 l 0.2,-1.6 c 0.2,-1.6 1,-3.1 2.4,-3.8 0.6,-0.4 1.2,-0.5 1.7,-0.5 m 0,-8 c -2,0 -3.9,0.5 -5.7,1.5 -3.5,2 -5.9,5.8 -6.3,10 l -0.2,1.6 c 0,0.3 0,0.5 0,0.8 v 1 c 0,0.1 0,0.2 0,0.3 1.2,29 2,46.5 2.1,48.7 0.5,6.9 3.8,9.9 6.6,11.3 1.6,0.8 3.3,1.2 5,1.2 3.3,0 6.5,-1.5 8.7,-4.2 2.5,-3 3.2,-6.8 3,-16.8 -0.1,-6.1 -0.2,-12.7 -0.2,-19.5 0,-4.2 0,-6.7 -0.1,-8.5 0.6,-0.8 1.3,-1.6 2.2,-2.3 0.6,-0.5 1.4,-0.8 2.5,-1 0.8,-0.2 1.6,-0.3 2.2,-0.3 0.4,0 0.6,0 0.8,0.1 0.3,0.1 0.4,0.1 0.5,0.2 1.9,1.8 3.3,2.9 4.6,3.6 0.3,0.2 0.8,0.5 1.7,1.1 2.5,1.8 5.2,2.7 7.8,2.7 3.5,0 6.8,-1.6 9.1,-4.5 2.1,-2.7 3.1,-6.1 2.6,-9.6 -0.5,-3.7 -2.7,-6.9 -6.1,-9 -0.4,-0.2 -1.2,-0.8 -2.7,-2 -2.7,-2.2 -5.7,-3.8 -9,-4.7 -2.5,-0.7 -5.4,-1.1 -8.6,-1.3 -0.6,0 -1.2,0 -1.7,0 -2.9,0 -5.8,0.4 -8.7,1.1 -0.9,0.2 -1.8,0.5 -2.6,0.8 -2.1,-1.5 -4.6,-2.3 -7.5,-2.3 z"
															id="path10"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g20">
																		<g
															id="g18">
																			<path
															class="st2"
															d="m 181.3,90.9 c 1.3,0 2.4,0.7 3,1.8 0.5,1 0.7,2.1 0.6,3.4 -0.2,1.2 -0.7,2.5 -1.6,3.7 -0.5,0.7 -1.4,2.2 -2.9,6 -1.2,3.1 -2.3,6.2 -3,9.1 -0.7,2.8 -1,5.8 -0.7,8.9 0.3,3.9 0.9,5.7 1.4,6.5 0.7,1.2 1.8,2.5 3.2,3.6 1.5,1.2 3.2,2.1 5,2.6 1.9,0.6 3.7,0.8 5.7,0.8 1.9,0 4,-0.3 6.1,-0.9 2,-0.5 3.8,-1.5 5.3,-2.9 1.5,-1.4 2.7,-2.7 3.4,-3.9 0.7,-1.2 1.3,-2.9 1.7,-5.1 0.5,-2.3 0.7,-5.1 0.7,-8.3 0,-3.1 -0.6,-5.9 -1.8,-8.3 -1.3,-2.6 -2.4,-5 -3.3,-7 -1.7,-3.9 0.3,-5.5 1.2,-6 1.1,-0.6 2.1,-0.9 3.2,-0.9 0.5,0 1.1,0.1 1.6,0.2 1.3,0.4 2.8,1.8 5.5,9.1 1.9,5.3 2.9,9.8 2.9,13.4 0,3.5 -0.3,6.6 -0.8,9.2 -0.5,2.6 -1.3,5.1 -2.4,7.5 -1.1,2.5 -3.2,4.8 -6.3,6.7 -2.9,1.9 -5.1,3 -6.7,3.4 -1.5,0.4 -3.8,0.6 -6.8,0.6 h -7 c -2,0 -4,-0.5 -6.1,-1.4 -2,-0.9 -3.9,-1.9 -5.7,-3.1 -1.9,-1.3 -3.7,-3.2 -5.4,-5.5 -1.7,-2.5 -2.5,-5.1 -2.6,-7.7 -0.1,-2.5 0,-5.4 0.4,-8.6 0.4,-3.2 0.9,-6.3 1.5,-9.2 0.7,-3 2.9,-8.2 6.7,-16 l 0.2,-0.3 0.3,-0.2 c 1.2,-0.8 2.4,-1.2 3.5,-1.2 m 0,-8 c -2.7,0 -5.4,0.9 -8.1,2.7 l -0.3,0.2 c -1.1,0.8 -2,1.8 -2.6,3 l -0.2,0.3 c -4.3,8.6 -6.5,14.1 -7.4,17.8 -0.7,3.2 -1.3,6.6 -1.7,10.1 -0.4,3.6 -0.5,6.9 -0.4,9.8 0.2,4.2 1.5,8.2 4,11.9 2.2,3.3 4.7,5.9 7.6,7.8 2.2,1.5 4.6,2.7 6.9,3.8 3.1,1.4 6.2,2.1 9.3,2.1 h 7 c 3.8,0 6.6,-0.3 8.8,-0.8 2.5,-0.6 5.3,-2 9,-4.3 4.4,-2.8 7.5,-6.2 9.3,-10.2 1.3,-2.9 2.3,-6 2.9,-9.1 0.6,-3.1 1,-6.8 1,-10.8 0,-4.6 -1.1,-10 -3.4,-16.1 -2.8,-7.7 -5.5,-12.4 -10.7,-14 -1.3,-0.4 -2.6,-0.6 -4,-0.6 -2.4,0 -4.8,0.6 -7,1.9 -2.3,1.3 -4.1,3.3 -5.1,5.6 -1,2.3 -1.6,5.9 0.4,10.6 0.9,2.1 2.1,4.6 3.4,7.3 0.6,1.3 1,2.9 1,4.7 0,2.6 -0.2,4.9 -0.6,6.6 -0.4,2 -0.8,2.7 -0.8,2.7 0,0.1 -0.5,0.8 -1.9,2.1 -0.5,0.5 -1.1,0.8 -1.9,1 -1.5,0.4 -2.8,0.6 -4,0.6 -1.1,0 -2.2,-0.2 -3.3,-0.5 -0.9,-0.3 -1.7,-0.7 -2.4,-1.2 -0.6,-0.5 -1,-0.9 -1.1,-1 -0.1,-0.3 -0.3,-1.4 -0.5,-3.5 -0.2,-2.3 0,-4.4 0.5,-6.3 0.7,-2.6 1.6,-5.3 2.7,-8.1 1.3,-3.1 1.9,-4.2 2,-4.4 1.7,-2.3 2.7,-4.8 3,-7.3 0.4,-3 -0.1,-5.8 -1.5,-8.3 -1.9,-3.9 -5.7,-6.1 -9.9,-6.1 z"
															id="path16"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g28">
																		<g
															id="g26">
																			<g
															id="g24">
																				<path
															class="st2"
															d="m 238.7,49 c 0.6,0 1.3,0.1 2.2,0.5 1.3,0.6 2.7,1.9 2.3,5.4 -0.2,2 -0.5,10.4 -0.8,24.9 -0.3,14.5 -0.3,23.2 -0.2,25.9 1.2,-1.3 2.5,-2.3 4.2,-3.1 1.9,-0.9 4.4,-1.8 7.6,-2.6 3.1,-0.8 5.7,-1.2 7.7,-1.4 0.3,0 0.6,0 0.9,0 1.8,0 3.8,0.4 5.8,1.1 2.2,0.8 4.1,1.5 5.6,2.1 1.7,0.7 3.1,1.5 4.4,2.5 1.4,1.1 2.5,2.9 3.5,5.4 0.9,2.3 1.7,4.4 2.5,6.3 0.8,2 1.4,4.4 1.6,7.1 0.3,2.6 0.5,5 0.6,7.2 0.1,2.2 0.1,4.5 0,6.7 -0.1,2.4 -0.8,4.6 -2,6.3 l -3.1,4.6 c -1.1,1.7 -2.9,3.4 -5.4,5 -2.5,1.7 -4.6,2.6 -6.3,2.9 -1.5,0.3 -3.6,0.6 -6.4,1 -2.1,0.3 -3.9,0.4 -5.4,0.4 -0.5,0 -1,0 -1.5,-0.1 -1.9,-0.1 -3.9,-0.8 -6,-1.9 -2.1,-1.1 -3.9,-2.6 -5.6,-4.3 l -4.3,-4.7 c -0.1,6.3 -0.5,8 -0.9,8.8 -1,2 -2.3,2.4 -3.3,2.4 -0.9,0 -2.5,-0.4 -3,-3.1 -0.3,-1.4 -0.4,-4 -0.2,-7.8 0.1,-3.7 0.3,-10.7 0.4,-20.9 0.1,-10.2 0.3,-17.2 0.6,-20.8 0.3,-3.5 0.4,-13.4 0.6,-29.2 0.2,-24.6 0.9,-25.2 1.6,-25.9 0.6,-0.4 1.3,-0.7 2.3,-0.7 m 20.9,100 c 0.9,0 1.7,-0.1 2.5,-0.3 2.1,-0.5 4.2,-1.1 6.1,-1.9 1.9,-0.7 3.4,-1.5 4.6,-2.5 1.3,-1 2.6,-2 3.9,-2.9 0.9,-0.6 1.5,-1.8 1.7,-3.5 0.2,-2.1 0.4,-5.2 0.4,-9 0,-3.8 -0.6,-7.3 -1.6,-10.4 -1,-3 -3.2,-5.8 -6.4,-8.4 -1.8,-0.8 -3.1,-1.4 -3.9,-2 -0.4,-0.2 -1.1,-0.5 -2.6,-0.5 h -4.8 c -1.6,0 -3.2,0.1 -5,0.4 -1.5,0.2 -2.8,0.8 -4,1.9 -1.3,1.2 -2.4,2.3 -3.1,3.2 -0.5,0.6 -1.4,2.1 -2.9,5.6 -1.2,2.8 -1.9,5.4 -2,7.7 -0.1,2.4 0.1,4.8 0.7,7 0.6,2.3 1.6,4.6 3.1,6.9 1.4,2.3 3,4.1 4.6,5.4 1.6,1.3 3.5,2.2 5.4,2.8 1.2,0.3 2.3,0.5 3.3,0.5 M 238.7,41 c -2.7,0 -5.2,0.9 -7.2,2.6 -3,2.6 -3.5,5.7 -3.9,9.4 -0.3,3.9 -0.5,11.1 -0.6,22.6 -0.2,19.6 -0.4,26.4 -0.6,28.7 -0.3,3.7 -0.5,10.9 -0.6,21.3 -0.1,10.1 -0.3,17.1 -0.4,20.7 -0.2,4.7 -0.1,7.6 0.4,9.7 1.4,7 6.7,9.6 10.8,9.6 3.3,0 6.4,-1.5 8.6,-4 0.6,0.3 1.1,0.7 1.7,1 3.1,1.6 6.1,2.6 9.1,2.8 0.7,0.1 1.4,0.1 2.1,0.1 1.9,0 4,-0.2 6.5,-0.5 2.8,-0.4 5,-0.7 6.5,-1 2.9,-0.5 5.9,-1.8 9.5,-4.1 3.3,-2.2 5.9,-4.7 7.6,-7.2 l 3.1,-4.6 c 2,-3 3.1,-6.4 3.3,-10.3 0.1,-2.5 0.1,-5.1 0,-7.6 -0.1,-2.3 -0.3,-4.8 -0.6,-7.5 -0.3,-3.4 -1.1,-6.6 -2.2,-9.3 -0.8,-1.9 -1.6,-4 -2.5,-6.2 -1.5,-4 -3.5,-6.9 -6.1,-8.8 -1.8,-1.4 -3.9,-2.6 -6.2,-3.6 -1.7,-0.7 -3.7,-1.5 -6,-2.3 -2.9,-1 -5.7,-1.5 -8.5,-1.5 -0.5,0 -1,0 -1.4,0 -2.5,0.2 -5.5,0.7 -9.1,1.6 -0.6,0.2 -1.2,0.3 -1.8,0.5 0,-3.4 0.1,-7.5 0.2,-12.8 0.3,-19.9 0.6,-23.5 0.7,-24.1 0.6,-4.9 -0.9,-11.1 -7,-13.7 -1.9,-1.1 -3.7,-1.5 -5.4,-1.5 z m 17.1,74.8 c 1.3,-0.2 2.5,-0.3 3.6,-0.3 h 4.3 c 0.8,0.4 1.7,0.9 2.7,1.3 1.6,1.4 2.7,2.8 3.1,4.1 0.8,2.3 1.2,4.9 1.2,7.8 0,3.5 -0.1,5.8 -0.2,7.2 -0.9,0.7 -1.8,1.4 -2.7,2.1 -0.2,0.2 -0.9,0.6 -2.4,1.2 -1.7,0.6 -3.4,1.2 -5.2,1.6 -0.2,0.1 -0.5,0.1 -0.7,0.1 -0.3,0 -0.6,0 -0.9,-0.1 -1,-0.3 -1.9,-0.8 -2.8,-1.4 -0.6,-0.5 -1.6,-1.5 -2.8,-3.4 -1,-1.6 -1.7,-3.2 -2.1,-4.6 -0.4,-1.5 -0.5,-3 -0.5,-4.6 0.1,-1.4 0.5,-3.1 1.3,-4.9 1.3,-2.9 1.9,-3.9 2,-4.1 0.4,-0.2 0.9,-0.9 2.1,-2 z"
															id="path22"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																			</g>
																		</g>
																	</g>
																	<g
															id="g34">
																		<g
															id="g32">
																			<path
															class="st2"
															d="m 350.1,94.9 c 1.5,0 2.7,0.9 3.4,2.4 0.6,1.3 1,3.8 1.3,7.6 0.3,3.6 0.5,10.6 0.6,20.8 0.1,10.4 0.3,17.2 0.4,20.9 0.1,3.9 0.1,6.4 -0.2,7.8 -0.5,2.7 -2.1,3.1 -3,3.1 -0.9,0 -2.3,-0.4 -3.3,-2.4 -0.4,-0.8 -0.8,-2.5 -0.9,-8.8 l -4.3,4.7 c -1.6,1.8 -3.5,3.2 -5.6,4.3 -2.1,1.1 -4.1,1.8 -6,1.9 -0.5,0 -1,0.1 -1.5,0.1 -1.5,0 -3.3,-0.1 -5.4,-0.4 -2.7,-0.4 -4.8,-0.7 -6.4,-1 -1.8,-0.3 -3.8,-1.2 -6.3,-2.9 -2.5,-1.6 -4.3,-3.3 -5.4,-5 l -3.1,-4.6 c -1.2,-1.8 -1.8,-3.9 -2,-6.3 -0.1,-2.2 -0.1,-4.5 0,-6.7 0.1,-2.2 0.3,-4.6 0.6,-7.2 0.3,-2.7 0.8,-5.1 1.6,-7.1 0.8,-1.9 1.6,-4 2.5,-6.3 1,-2.6 2.2,-4.4 3.5,-5.4 1.3,-1 2.7,-1.8 4.4,-2.5 1.6,-0.7 3.5,-1.4 5.6,-2.1 2,-0.7 4,-1.1 5.8,-1.1 0.3,0 0.6,0 0.9,0 2,0.1 4.6,0.6 7.7,1.4 3.2,0.8 5.7,1.7 7.6,2.6 1.2,0.6 2.4,1.4 3.3,2.3 -0.1,-1.2 -0.2,-2.2 -0.3,-3.1 -0.1,-1.6 0,-3.1 0.5,-4.3 0.6,-1.5 1.8,-2.5 3.3,-2.7 0.4,0 0.5,0 0.7,0 m -20.6,54.2 c 1.1,0 2.1,-0.2 3.2,-0.5 2,-0.6 3.8,-1.5 5.4,-2.8 1.6,-1.3 3.2,-3.1 4.6,-5.4 1.4,-2.3 2.5,-4.6 3.1,-6.9 0.6,-2.3 0.8,-4.6 0.7,-7 -0.1,-2.4 -0.8,-5 -2,-7.7 -1.5,-3.5 -2.4,-5 -2.9,-5.6 -0.7,-0.9 -1.7,-2 -3.1,-3.2 -1.2,-1.1 -2.5,-1.7 -4,-1.9 -1.7,-0.2 -3.4,-0.4 -5,-0.4 h -4.8 c -1.5,0 -2.3,0.3 -2.6,0.5 -0.8,0.5 -2.1,1.2 -3.9,2 -3.2,2.6 -5.4,5.4 -6.5,8.4 -1.1,3.1 -1.6,6.7 -1.6,10.4 0,3.9 0.1,6.9 0.4,9 0.2,1.7 0.8,2.9 1.7,3.5 1.3,0.9 2.6,1.9 3.9,2.9 1.1,0.9 2.7,1.7 4.6,2.5 2,0.7 4,1.4 6.1,1.9 1,0.2 1.9,0.3 2.7,0.3 m 20.6,-62.2 c -0.5,0 -1,0 -1.5,0.1 -3.9,0.5 -7.1,2.7 -9,6 -0.8,-0.2 -1.6,-0.4 -2.5,-0.7 -3.6,-0.9 -6.6,-1.4 -9.1,-1.6 -0.5,0 -1,0 -1.5,0 -2.8,0 -5.6,0.5 -8.5,1.5 -2.3,0.8 -4.4,1.6 -6,2.3 -2.3,1 -4.4,2.2 -6.2,3.6 -2.6,2 -4.5,4.9 -6.1,8.8 -0.9,2.3 -1.7,4.4 -2.5,6.2 -1.1,2.7 -1.8,5.9 -2.2,9.3 -0.3,2.7 -0.5,5.2 -0.6,7.5 -0.1,2.5 -0.1,5.1 0,7.6 0.2,3.9 1.3,7.3 3.3,10.3 l 3.1,4.6 c 1.7,2.6 4.3,5 7.6,7.2 3.5,2.3 6.5,3.7 9.5,4.1 1.6,0.3 3.8,0.6 6.5,1 2.5,0.4 4.6,0.5 6.5,0.5 0.7,0 1.4,0 2.1,-0.1 3,-0.2 6,-1.2 9.1,-2.8 0.6,-0.3 1.1,-0.6 1.7,-1 2.2,2.6 5.2,4 8.6,4 4.1,0 9.4,-2.5 10.8,-9.5 0.4,-2.1 0.5,-5 0.4,-9.7 -0.1,-3.6 -0.2,-10.4 -0.4,-20.7 -0.1,-10.3 -0.3,-17.5 -0.6,-21.3 -0.4,-5 -0.9,-8 -1.9,-10.3 -1.9,-4.2 -6,-6.9 -10.6,-6.9 z m -24.8,28.8 h 4.3 c 1.1,0 2.4,0.1 3.6,0.3 1.2,1.1 1.8,1.8 2,2 0.1,0.2 0.7,1.1 2,4.1 0.8,1.8 1.3,3.5 1.3,4.9 0.1,1.6 -0.1,3.1 -0.5,4.6 -0.4,1.5 -1.1,3 -2.1,4.6 -1.2,1.9 -2.2,2.9 -2.8,3.4 -0.8,0.7 -1.8,1.1 -2.8,1.4 -0.3,0.1 -0.6,0.1 -0.9,0.1 -0.2,0 -0.5,0 -0.7,-0.1 -1.8,-0.4 -3.5,-0.9 -5.2,-1.6 -1.5,-0.6 -2.2,-1 -2.4,-1.2 -0.9,-0.7 -1.8,-1.4 -2.7,-2.1 -0.1,-1.4 -0.2,-3.6 -0.2,-7.2 0,-2.9 0.4,-5.5 1.2,-7.8 0.5,-1.3 1.5,-2.7 3.1,-4.1 1.2,-0.5 2.1,-0.9 2.8,-1.3 z"
															id="path30"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g40">
																		<g
															id="g38">
																			<path
															class="st2"
															d="m 377.3,143.5 v 1.1 c 0.4,0 0.8,0.1 1.2,0.2 0.7,0.2 1.5,0.6 2.6,1.4 1.2,0.9 2,2 2.3,3.3 0.4,1.5 0.1,2.9 -0.9,4 -0.8,1 -2,1.7 -3.4,2.2 -0.6,0.2 -1.2,0.3 -1.8,0.3 -1,0 -2.1,-0.2 -3.2,-0.7 -2,-0.9 -3.2,-2 -3.4,-3.5 -0.2,-1.1 -0.1,-2.3 0.2,-3.6 0.4,-1.7 1.8,-3 4.4,-4 l 2,-0.7 m 0,-8 c -0.9,0 -1.9,0.2 -2.8,0.5 l -2,0.8 c -6.5,2.4 -8.7,6.6 -9.4,9.7 -0.5,2.2 -0.6,4.4 -0.3,6.5 0.4,2.5 1.9,7.1 8.2,9.7 2.1,0.9 4.2,1.3 6.3,1.3 1.5,0 3,-0.2 4.4,-0.7 2.8,-0.9 5.2,-2.5 7,-4.7 2.6,-3.1 3.5,-7.1 2.5,-11.1 -0.8,-3.2 -2.7,-6 -5.4,-7.9 -0.9,-0.6 -1.7,-1.2 -2.5,-1.6 -0.4,-0.4 -0.8,-0.8 -1.3,-1.2 -1.5,-0.8 -3.1,-1.3 -4.7,-1.3 z"
															id="path36"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g46">
																		<g
															id="g44">
																			<path
															class="st2"
															d="m 404,68.3 c 1.3,0 2.7,0.3 4.3,0.9 1.8,0.6 3.1,1.8 4.1,3.6 0.9,1.6 1.4,3.4 1.5,5.4 0.1,2 -0.3,4.2 -1.3,6.5 -1.1,2.5 -2.3,3.9 -3.7,4.4 -1.2,0.4 -2.4,0.7 -3.6,0.7 -1.2,0 -2.6,-0.3 -4,-0.9 l -0.4,-0.1 -0.2,-0.3 c -1,-1.3 -1.8,-2.4 -2.4,-3.2 -0.5,-0.8 -1,-1.6 -1.4,-2.5 -0.5,-1 -0.7,-2.1 -0.7,-3.4 0,-1.1 0.1,-2.2 0.2,-3.4 0.1,-1.3 0.4,-2.5 0.9,-3.5 0.5,-1.2 1.4,-2.2 2.7,-3 1.1,-0.9 2.5,-1.2 4,-1.2 m 1.3,14.1 c 0.3,0 0.6,-0.1 0.9,-0.2 v 0 c 0,0 0.3,-0.2 0.8,-1.3 0.4,-0.9 0.5,-1.6 0.5,-2.3 -0.1,-0.8 -0.3,-1.5 -0.6,-2.1 -0.2,-0.4 -0.5,-0.7 -0.9,-0.8 -0.5,-0.2 -0.9,-0.3 -1.3,-0.3 -0.3,0 -0.6,0.1 -0.9,0.3 -0.3,0.2 -0.4,0.4 -0.5,0.6 -0.1,0.3 -0.2,0.7 -0.2,1.1 0,0.6 0,1.1 0,1.7 0,0.4 0,0.8 0.1,1 0.1,0.3 0.2,0.6 0.4,0.9 0.1,0.2 0.4,0.6 1,1.3 0.1,0.1 0.4,0.1 0.7,0.1 m 1.8,9.6 c 1.1,0 2.9,0.5 3.4,3.8 0.3,1.7 1,9.5 2.3,23.7 1.7,19 1.8,22.4 1.7,23.3 -0.2,1.8 -0.8,3 -1.9,3.6 -0.4,0.2 -1,0.5 -1.7,0.5 -0.6,0 -1.3,-0.2 -2.2,-0.6 -1.3,-0.8 -2.1,-2.2 -2.3,-4.2 -0.1,-1.5 -1.2,-14.9 -3.2,-40 -0.5,-1.4 -0.8,-2.8 -0.8,-4.4 0,-1.8 0.4,-3.1 1.1,-4 0.7,-0.9 1.8,-1.7 3.6,-1.7 M 404,60.3 c -3,0 -5.8,0.8 -8.4,2.4 -2.7,1.7 -4.7,3.9 -5.8,6.6 -0.8,1.8 -1.2,3.7 -1.5,5.8 -0.2,1.5 -0.2,2.9 -0.2,4.3 0,2.5 0.5,4.8 1.6,6.9 0.6,1.1 1.2,2.2 1.9,3.3 0.7,1 1.6,2.2 2.8,3.7 l 0.2,0.3 c 0.1,0.1 0.2,0.3 0.3,0.4 -0.2,1.1 -0.3,2.3 -0.3,3.5 0,2.1 0.3,4.1 0.9,6 2,24.2 3,37.5 3.2,39.1 0.5,6.3 4.2,9.3 6.3,10.5 2,1.1 4,1.7 6.1,1.7 2,0 4,-0.6 5.8,-1.6 1.9,-1.1 5.1,-3.9 5.7,-9.7 0.1,-1.3 0.3,-2.8 -1.7,-24.8 -1.7,-18.9 -2.2,-22.9 -2.4,-24.2 -0.2,-1 -0.4,-2 -0.8,-2.9 0.8,-1.1 1.5,-2.4 2.2,-3.9 1.5,-3.5 2.2,-6.9 1.9,-10.2 -0.2,-3.2 -1.1,-6.1 -2.5,-8.7 -1.9,-3.4 -4.8,-5.9 -8.3,-7.3 -2.5,-0.8 -4.8,-1.2 -7,-1.2 z"
															id="path42"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g52">
																		<g
															id="g50">
																			<path
															class="st2"
															d="m 452,55.4 c 0.2,0 0.4,0 0.6,0 2.2,0.3 2.7,3.3 3,6.2 0.3,3.1 0.5,8.2 0.6,15.4 0.1,7.3 0.3,9.9 0.4,10.8 0.3,0.1 0.8,0.1 1.7,0.1 0.5,0 1.1,0 1.8,-0.1 3,-0.2 5.4,-0.3 7.1,-0.4 0.1,0 0.3,0 0.4,0 1.9,0 3.4,0.5 4.2,1.6 0.5,0.6 1.6,2.4 -0.4,4.6 -1.2,1.3 -3.2,2 -6.3,2 -2.5,0 -4.9,0.1 -7,0.2 -1.1,0.1 -1.6,0.2 -1.9,0.3 0,1.6 -0.1,7.3 -0.2,18 -0.1,11.4 -0.1,20.3 0.2,26.6 0.4,8.7 -0.4,11.2 -1.1,12.3 -0.7,1.2 -1.9,2.8 -3.6,2.8 -0.9,0 -2.1,-0.4 -3.2,-2.2 -0.7,-1.3 -1,-3.4 -0.8,-6.8 0.2,-2.9 0.1,-12 -0.1,-27 -0.2,-12.6 -0.3,-20.7 -0.3,-23.2 -0.3,0 -0.8,-0.1 -1.5,-0.1 -1,0 -2.5,0.1 -4.7,0.3 -4.1,0.4 -7,0.6 -8.9,0.6 -0.6,0 -1.1,0 -1.4,-0.1 -3.1,-0.4 -3.4,-2.2 -3.4,-3 0,-1 0.4,-2.3 2.2,-3.4 0.6,-0.4 1.7,-1 18.3,-2.2 -0.3,-6.5 -0.5,-13 -0.6,-19.4 v 0 c -0.2,-10.1 0.7,-11.8 1.5,-12.6 1.4,-1 2.5,-1.3 3.4,-1.3 m 0,-8 c -3.3,0 -6.4,1.4 -8.9,3.9 -3.2,3.2 -4,7.3 -3.8,18.4 0.1,3.9 0.2,7.9 0.3,11.9 -11.1,1 -12.3,1.6 -14,2.7 -4,2.3 -6.2,6.1 -6.2,10.3 0,2.4 0.8,4.7 2.3,6.6 1.3,1.7 3.9,3.8 8.3,4.3 0.7,0.1 1.4,0.1 2.3,0.1 1.7,0 4,-0.1 7.2,-0.4 0.1,3.9 0.1,8.9 0.2,14.9 0.3,18.4 0.2,24.5 0.1,26.4 -0.3,5 0.3,8.5 1.9,11.2 2.3,4 6,6.2 10.1,6.2 3,0 7.2,-1.2 10.5,-6.8 1.9,-3.3 2.5,-7.8 2.2,-16.7 -0.2,-6.1 -0.3,-14.9 -0.2,-26.1 0,-4.3 0.1,-7.9 0.1,-10.6 0.3,0 0.6,0 1,0 5.4,0 9.6,-1.6 12.3,-4.7 4.6,-5.2 3.5,-11.3 0.5,-15 -1.7,-2 -4.9,-4.5 -10.4,-4.5 -0.2,0 -0.5,0 -0.7,0 -0.8,0 -1.7,0.1 -2.7,0.1 0,-0.8 0,-1.7 -0.1,-2.7 -0.1,-7.6 -0.3,-12.7 -0.7,-16 -0.2,-1.8 -0.5,-4 -1.3,-6.2 -1.5,-4 -4.6,-6.6 -8.5,-7.1 -0.6,-0.2 -1.2,-0.2 -1.8,-0.2 z"
															id="path48"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																</g>
															</g>
															<g
															id="logo_bianco_con_bordo"
															class="st0"
															style="display:none"
															transform="translate(-34.723458,-61.842024)">
																<g
															class="st1"
															id="g123"
															style="display:inline">
																	<g
															id="g63">
																		<g
															id="g61">
																			<path
															class="st3"
															d="m 94.1,161.5 c -2.9,0 -5.4,-1.7 -6.8,-4.6 -0.2,-0.4 -0.4,-0.8 -0.5,-1.4 -1.5,1.3 -3.1,2.4 -4.8,3.4 -2.6,1.4 -5.1,2.2 -7.5,2.4 -0.6,0 -1.2,0.1 -1.8,0.1 -1.7,0 -3.6,-0.2 -5.9,-0.5 -2.7,-0.4 -4.9,-0.7 -6.5,-1 -2.3,-0.4 -4.9,-1.5 -7.9,-3.5 -2.9,-1.9 -5.1,-4 -6.5,-6.1 l -3.1,-4.6 c -1.6,-2.3 -2.5,-5.1 -2.6,-8.3 -0.1,-2.4 -0.1,-4.8 0,-7.2 0.1,-2.3 0.3,-4.7 0.6,-7.3 0.3,-3.1 0.9,-5.8 1.9,-8.2 0.8,-1.9 1.6,-4 2.5,-6.3 1.3,-3.3 2.8,-5.6 4.8,-7.1 1.5,-1.2 3.3,-2.2 5.3,-3 1.6,-0.7 3.6,-1.4 5.8,-2.2 2.4,-0.9 4.8,-1.3 7.1,-1.3 0.4,0 0.8,0 1.2,0 2.2,0.2 5.1,0.7 8.4,1.5 2.2,0.5 4.2,1.1 5.8,1.8 0.1,-0.6 0.3,-1.2 0.5,-1.8 1.1,-2.9 3.5,-4.9 6.6,-5.3 0.3,0 0.7,-0.1 1,-0.1 3.1,0 5.7,1.8 7,4.8 0.8,1.8 1.3,4.5 1.6,8.9 0.3,3.7 0.5,10.7 0.6,21 0.1,10.2 0.3,17.1 0.4,20.8 0.1,4.3 0.1,7 -0.3,8.7 -0.9,4.7 -4.2,6.4 -6.9,6.4 z M 56.4,138.4 c 1.3,0.9 2.6,1.9 3.9,2.9 0.8,0.6 2,1.3 3.5,1.8 1.8,0.7 3.7,1.3 5.7,1.7 0.5,0.1 1.1,0.2 1.6,0.2 v 0 c 0.7,0 1.4,-0.1 2.1,-0.3 1.5,-0.4 2.9,-1.1 4.1,-2.1 1.3,-1 2.5,-2.5 3.7,-4.4 1.2,-1.9 2.1,-3.9 2.6,-5.7 0.5,-1.9 0.7,-3.8 0.6,-5.8 -0.1,-1.9 -0.7,-4 -1.7,-6.3 -1.6,-3.6 -2.3,-4.7 -2.4,-4.8 -0.4,-0.5 -1.1,-1.4 -2.6,-2.7 -0.6,-0.5 -1.2,-0.8 -1.9,-0.9 -1.5,-0.2 -3,-0.3 -4.4,-0.3 h -4.8 c -0.3,0 -0.6,0 -0.7,0 -0.9,0.6 -2.1,1.2 -3.7,1.9 -2.4,2 -4,4.1 -4.8,6.3 -0.9,2.7 -1.4,5.8 -1.4,9.1 0,3.7 0.1,6.6 0.3,8.6 0.2,0.4 0.3,0.7 0.3,0.8 z"
															id="path57"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																			<path
															class="st2"
															d="m 91.7,94.9 c 1.5,0 2.7,0.9 3.4,2.4 0.6,1.3 1,3.8 1.3,7.6 0.3,3.6 0.5,10.6 0.6,20.8 0.1,10.2 0.3,17.2 0.4,20.9 0.1,3.9 0.1,6.4 -0.2,7.8 -0.5,2.7 -2.1,3.1 -3,3.1 -0.9,0 -2.3,-0.4 -3.3,-2.4 -0.4,-0.8 -0.8,-2.5 -0.9,-8.8 l -4.3,4.7 c -1.6,1.8 -3.5,3.2 -5.6,4.3 -2.1,1.1 -4.1,1.8 -6,1.9 -0.5,0 -0.9,0.1 -1.5,0.1 -1.5,0 -3.3,-0.1 -5.4,-0.4 -2.7,-0.4 -4.8,-0.7 -6.4,-1 C 59,155.6 57,154.7 54.5,153 52,151.4 50.2,149.7 49.1,148 L 46,143.4 c -1.2,-1.7 -1.8,-3.9 -2,-6.3 -0.1,-2.2 -0.1,-4.5 0,-6.7 0.1,-2.2 0.3,-4.6 0.6,-7.2 0.3,-2.7 0.8,-5.1 1.6,-7.1 0.8,-1.9 1.6,-4 2.5,-6.3 1,-2.6 2.2,-4.4 3.5,-5.4 1.3,-1 2.7,-1.8 4.4,-2.5 1.6,-0.7 3.5,-1.4 5.6,-2.1 2,-0.7 4,-1.1 5.8,-1.1 0.3,0 0.6,0 0.9,0 2,0.1 4.6,0.6 7.7,1.4 3.2,0.8 5.7,1.7 7.6,2.6 1.2,0.6 2.4,1.4 3.3,2.3 -0.1,-1.2 -0.2,-2.2 -0.3,-3.1 -0.1,-1.6 0,-3.1 0.5,-4.3 0.6,-1.5 1.8,-2.5 3.3,-2.7 0.4,0 0.5,0 0.7,0 m -20.6,54.2 c 1.1,0 2.1,-0.2 3.2,-0.5 2,-0.6 3.8,-1.5 5.4,-2.8 1.6,-1.3 3.2,-3.1 4.6,-5.4 1.4,-2.3 2.5,-4.6 3.1,-6.9 0.6,-2.3 0.8,-4.6 0.7,-7 -0.1,-2.4 -0.8,-5 -2,-7.7 -1.5,-3.5 -2.4,-5 -2.9,-5.6 -0.7,-0.9 -1.7,-2 -3.1,-3.2 -1.2,-1.1 -2.5,-1.7 -4,-1.9 -1.7,-0.2 -3.4,-0.4 -5,-0.4 h -4.8 c -1.5,0 -2.3,0.3 -2.6,0.5 -0.8,0.5 -2.1,1.2 -3.9,2 -3.2,2.6 -5.4,5.4 -6.4,8.4 -1.1,3.1 -1.6,6.7 -1.6,10.4 0,3.9 0.1,6.9 0.4,9 0.2,1.7 0.8,2.9 1.7,3.5 1.3,0.9 2.6,1.9 3.9,2.9 1.1,0.9 2.7,1.7 4.6,2.5 2,0.7 4,1.4 6.1,1.9 0.9,0.2 1.8,0.3 2.6,0.3 M 91.7,86.9 c -0.5,0 -1,0 -1.4,0.1 -3.9,0.5 -7.2,2.7 -9,6.1 -0.8,-0.2 -1.6,-0.4 -2.5,-0.7 -3.6,-0.9 -6.6,-1.4 -9.1,-1.6 -0.5,0 -1,0 -1.5,0 -2.7,0 -5.6,0.5 -8.5,1.5 -2.3,0.8 -4.3,1.6 -6,2.3 -2.3,1 -4.4,2.2 -6.2,3.6 -2.6,2 -4.5,4.9 -6.1,8.8 -0.9,2.3 -1.7,4.3 -2.5,6.2 -1.1,2.7 -1.8,5.9 -2.2,9.3 -0.3,2.7 -0.5,5.2 -0.6,7.5 -0.2,2.5 -0.2,5.1 0,7.6 0.2,3.9 1.3,7.3 3.3,10.3 l 3.1,4.6 c 1.7,2.6 4.3,5 7.6,7.2 3.5,2.3 6.5,3.7 9.5,4.2 1.6,0.3 3.8,0.6 6.5,1 2.5,0.4 4.6,0.5 6.5,0.5 0.7,0 1.4,0 2.1,-0.1 3,-0.2 6,-1.2 9.1,-2.8 0.6,-0.3 1.1,-0.6 1.7,-1 2.2,2.6 5.2,4 8.6,4 4.1,0 9.4,-2.5 10.8,-9.6 0.4,-2.1 0.5,-5 0.4,-9.7 -0.1,-3.6 -0.3,-10.6 -0.4,-20.7 -0.1,-10.4 -0.3,-17.5 -0.6,-21.3 -0.4,-5 -0.9,-8 -1.9,-10.3 -2,-4.3 -6.1,-7 -10.7,-7 z m -24.8,28.8 h 4.3 c 1.1,0 2.4,0.1 3.6,0.3 1.2,1.1 1.8,1.8 2,2 0.1,0.2 0.7,1.1 2,4.1 0.8,1.8 1.3,3.5 1.3,4.9 0.1,1.6 -0.1,3.1 -0.5,4.6 -0.4,1.5 -1.1,3 -2.1,4.6 -1.2,1.9 -2.2,2.9 -2.8,3.4 -0.8,0.6 -1.8,1.1 -2.8,1.4 -0.3,0.1 -0.6,0.1 -0.9,0.1 -0.2,0 -0.5,0 -0.7,-0.1 -1.8,-0.4 -3.5,-0.9 -5.2,-1.6 -1.5,-0.6 -2.2,-1 -2.4,-1.2 -0.9,-0.7 -1.8,-1.4 -2.7,-2.1 -0.1,-1.4 -0.2,-3.6 -0.2,-7.2 0,-2.9 0.4,-5.5 1.2,-7.8 0.5,-1.3 1.5,-2.7 3.1,-4.1 1.2,-0.5 2.1,-0.9 2.8,-1.3 z m -6.7,21.5 v 0 z"
															id="path59"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g71">
																		<g
															id="g69">
																			<path
															class="st3"
															d="m 117.8,161.5 c -1.1,0 -2.2,-0.3 -3.2,-0.8 -2.6,-1.3 -4.1,-4 -4.4,-8 -0.1,-2.2 -0.9,-19.6 -2.1,-48.6 0,-0.1 0,-1.1 0,-1.1 0,-0.1 0,-0.3 0,-0.4 l 0.2,-1.6 c 0.3,-2.9 1.9,-5.5 4.3,-6.9 1.2,-0.7 2.4,-1 3.7,-1 2.8,0 5.1,1.2 6.4,3.2 1.4,-0.8 2.9,-1.3 4.6,-1.8 2.6,-0.6 5.2,-1 7.7,-1 0.5,0 1,0 1.5,0 2.9,0.1 5.6,0.5 7.8,1.1 2.7,0.7 5.2,2 7.4,3.9 1.6,1.3 2.6,2 3.1,2.3 3.1,1.9 4,4.4 4.3,6.2 0.3,2.4 -0.3,4.7 -1.7,6.5 -1.6,1.9 -3.7,3 -6,3 -1.8,0 -3.6,-0.6 -5.5,-2 -0.8,-0.5 -1.4,-1 -1.9,-1.3 -1,-0.6 -2.2,-1.6 -3.9,-3.1 -0.7,-0.6 -1.4,-1 -2.4,-1.2 -0.5,-0.1 -1,-0.1 -1.6,-0.1 -0.9,0 -1.9,0.1 -3,0.3 -1.7,0.3 -3.1,0.9 -4.2,1.8 -1.3,1 -2.4,2.2 -3.2,3.4 -0.2,0.4 -0.4,0.6 -0.6,0.9 0.1,1.6 0.1,4.3 0.1,9.6 0,6.9 0.1,13.5 0.2,19.6 0.2,9.8 -0.5,12.3 -2,14.2 -1.4,1.9 -3.4,2.9 -5.6,2.9 z"
															id="path65"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																			<path
															class="st2"
															d="m 116.3,97.1 c 1.2,0 2.5,0.4 3.1,1.5 0.8,1.7 0.7,4.1 0.9,4.8 0.3,-0.3 0.6,-0.7 1,-1.1 1.7,-1.9 4,-3.2 6.9,-3.9 2.2,-0.6 4.5,-0.8 6.8,-0.8 0.4,0 0.9,0 1.3,0 2.6,0.1 5,0.5 7,1 2.2,0.6 4.2,1.7 5.9,3.1 1.4,1.2 2.6,2.1 3.5,2.6 1.4,0.9 2.2,2 2.4,3.4 0.2,1.3 -0.1,2.5 -0.9,3.5 -1,1.3 -2.1,1.5 -2.9,1.5 -1,0 -2,-0.4 -3.2,-1.2 -0.9,-0.6 -1.6,-1.1 -2.2,-1.5 -0.7,-0.4 -1.8,-1.3 -3.3,-2.7 -1.2,-1.1 -2.6,-1.8 -4.3,-2.1 -0.7,-0.1 -1.5,-0.2 -2.3,-0.2 -1.2,0 -2.4,0.1 -3.8,0.4 -2.3,0.5 -4.3,1.3 -5.9,2.6 -1.6,1.3 -3,2.8 -4.1,4.4 -0.8,1.3 -1.1,1.9 -1.3,2.1 0.1,1.2 0.2,3.8 0.2,10.5 0,6.9 0.1,13.6 0.2,19.7 0.2,9.2 -0.5,10.8 -1.1,11.5 -0.7,0.9 -1.6,1.3 -2.5,1.3 -0.5,0 -0.9,-0.1 -1.4,-0.3 -1.3,-0.6 -2,-2.2 -2.2,-4.7 C 114,150.6 113.3,135 112,104 v -1 l 0.2,-1.6 c 0.2,-1.6 1,-3.1 2.4,-3.8 0.6,-0.4 1.2,-0.5 1.7,-0.5 m 0,-8 c -2,0 -3.9,0.5 -5.7,1.5 -3.5,2 -5.9,5.8 -6.3,10 l -0.2,1.6 c 0,0.3 0,0.5 0,0.8 v 1 c 0,0.1 0,0.2 0,0.3 1.2,29 2,46.5 2.1,48.7 0.5,6.9 3.8,9.9 6.6,11.3 1.6,0.8 3.3,1.2 5,1.2 3.3,0 6.5,-1.5 8.7,-4.2 2.5,-3 3.2,-6.8 3,-16.8 -0.1,-6.1 -0.2,-12.7 -0.2,-19.5 0,-4.2 0,-6.7 -0.1,-8.5 0.6,-0.8 1.3,-1.6 2.2,-2.3 0.6,-0.5 1.4,-0.8 2.5,-1 0.8,-0.2 1.6,-0.3 2.2,-0.3 0.4,0 0.6,0 0.8,0.1 0.3,0.1 0.4,0.1 0.5,0.2 1.9,1.8 3.3,2.9 4.6,3.6 0.3,0.2 0.8,0.5 1.7,1.1 2.5,1.8 5.2,2.7 7.8,2.7 3.5,0 6.8,-1.6 9.1,-4.5 2.1,-2.7 3.1,-6.1 2.6,-9.6 -0.5,-3.7 -2.7,-6.9 -6.1,-9 -0.4,-0.2 -1.2,-0.8 -2.7,-2 -2.7,-2.2 -5.7,-3.8 -9,-4.7 -2.5,-0.7 -5.4,-1.1 -8.6,-1.3 -0.6,0 -1.2,0 -1.7,0 -2.9,0 -5.8,0.4 -8.7,1.1 -0.9,0.2 -1.8,0.5 -2.6,0.8 -2.1,-1.5 -4.6,-2.3 -7.5,-2.3 z"
															id="path67"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g79">
																		<g
															id="g77">
																			<path
															class="st3"
															d="m 188.5,148.4 c -2.5,0 -5.2,-0.6 -7.7,-1.7 -2.2,-0.9 -4.3,-2.1 -6.3,-3.5 -2.4,-1.6 -4.6,-3.8 -6.5,-6.6 -2.1,-3.1 -3.2,-6.4 -3.3,-9.8 -0.1,-2.7 0,-5.8 0.4,-9.2 0.4,-3.4 0.9,-6.6 1.6,-9.7 0.8,-3.3 3,-8.7 7.1,-16.9 l 0.2,-0.3 c 0.3,-0.6 0.8,-1.1 1.3,-1.5 l 0.3,-0.2 c 2,-1.4 3.9,-2 5.8,-2 2.8,0 5.2,1.5 6.6,3.9 0.9,1.7 1.3,3.8 1,5.9 -0.3,1.9 -1,3.7 -2.3,5.5 -0.1,0.1 -0.8,1.1 -2.4,5.2 -1.2,3 -2.1,5.8 -2.8,8.6 -0.6,2.4 -0.8,4.9 -0.6,7.6 0.3,3.8 0.9,4.9 0.9,5 0.3,0.5 0.9,1.4 2.2,2.4 1.1,0.9 2.4,1.5 3.7,1.9 1.5,0.5 3,0.7 4.5,0.7 1.6,0 3.2,-0.2 5,-0.7 1.4,-0.4 2.6,-1 3.6,-1.9 1.6,-1.4 2.3,-2.4 2.6,-3 0.3,-0.4 0.8,-1.6 1.3,-3.9 0.4,-2 0.6,-4.5 0.6,-7.4 0,-2.5 -0.5,-4.6 -1.4,-6.5 -1.3,-2.6 -2.4,-5 -3.3,-7.1 -2.5,-5.6 0,-9.5 3,-11.1 1.7,-0.9 3.4,-1.4 5.1,-1.4 0.9,0 1.9,0.1 2.8,0.4 3.2,1 5.3,4 8.1,11.6 2.1,5.7 3.2,10.7 3.2,14.7 0,3.8 -0.3,7.2 -0.9,10 -0.6,2.9 -1.5,5.7 -2.7,8.3 -1.5,3.3 -4.1,6.1 -7.8,8.4 -3.4,2.1 -5.9,3.3 -7.9,3.8 -1.9,0.5 -4.4,0.7 -7.8,0.7 h -7.2 z"
															id="path73"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																			<path
															class="st2"
															d="m 181.3,90.9 c 1.3,0 2.4,0.7 3,1.8 0.5,1 0.7,2.1 0.6,3.4 -0.2,1.2 -0.7,2.5 -1.6,3.7 -0.5,0.7 -1.4,2.2 -2.9,6 -1.2,3.1 -2.3,6.2 -3,9.1 -0.7,2.8 -1,5.8 -0.7,8.9 0.3,3.9 0.9,5.7 1.4,6.5 0.7,1.2 1.8,2.5 3.2,3.6 1.5,1.2 3.2,2.1 5,2.6 1.9,0.6 3.7,0.8 5.7,0.8 1.9,0 4,-0.3 6.1,-0.9 2,-0.5 3.8,-1.5 5.3,-2.9 1.5,-1.4 2.7,-2.7 3.4,-3.9 0.7,-1.2 1.3,-2.9 1.7,-5.1 0.5,-2.3 0.7,-5.1 0.7,-8.3 0,-3.1 -0.6,-5.9 -1.8,-8.3 -1.3,-2.6 -2.4,-5 -3.3,-7 -1.7,-3.9 0.3,-5.5 1.2,-6 1.1,-0.6 2.1,-0.9 3.2,-0.9 0.5,0 1.1,0.1 1.6,0.2 1.3,0.4 2.8,1.8 5.5,9.1 1.9,5.3 2.9,9.8 2.9,13.4 0,3.5 -0.3,6.6 -0.8,9.2 -0.5,2.6 -1.3,5.1 -2.4,7.5 -1.1,2.5 -3.2,4.8 -6.3,6.7 -2.9,1.9 -5.1,3 -6.7,3.4 -1.5,0.4 -3.8,0.6 -6.8,0.6 h -7 c -2,0 -4,-0.5 -6.1,-1.4 -2,-0.9 -3.9,-1.9 -5.7,-3.1 -1.9,-1.3 -3.7,-3.2 -5.4,-5.5 -1.7,-2.5 -2.5,-5.1 -2.6,-7.7 -0.1,-2.5 0,-5.4 0.4,-8.6 0.4,-3.2 0.9,-6.3 1.5,-9.2 0.7,-3 2.9,-8.2 6.7,-16 l 0.2,-0.3 0.3,-0.2 c 1.2,-0.8 2.4,-1.2 3.5,-1.2 m 0,-8 c -2.7,0 -5.4,0.9 -8.1,2.7 l -0.3,0.2 c -1.1,0.8 -2,1.8 -2.6,3 l -0.2,0.3 c -4.3,8.6 -6.5,14.1 -7.4,17.8 -0.7,3.2 -1.3,6.6 -1.7,10.1 -0.4,3.6 -0.5,6.9 -0.4,9.8 0.2,4.2 1.5,8.2 4,11.9 2.2,3.3 4.7,5.9 7.6,7.8 2.2,1.5 4.6,2.7 6.9,3.8 3.1,1.4 6.2,2.1 9.3,2.1 h 7 c 3.8,0 6.6,-0.3 8.8,-0.8 2.5,-0.6 5.3,-2 9,-4.3 4.4,-2.8 7.5,-6.2 9.3,-10.2 1.3,-2.9 2.3,-6 2.9,-9.1 0.6,-3.1 1,-6.8 1,-10.8 0,-4.6 -1.1,-10 -3.4,-16.1 -2.8,-7.7 -5.5,-12.4 -10.7,-14 -1.3,-0.4 -2.6,-0.6 -4,-0.6 -2.4,0 -4.8,0.6 -7,1.9 -2.3,1.3 -4.1,3.3 -5.1,5.6 -1,2.3 -1.6,5.9 0.4,10.6 0.9,2.1 2.1,4.6 3.4,7.3 0.6,1.3 1,2.9 1,4.7 0,2.6 -0.2,4.9 -0.6,6.6 -0.4,2 -0.8,2.7 -0.8,2.7 0,0.1 -0.5,0.8 -1.9,2.1 -0.5,0.5 -1.1,0.8 -1.9,1 -1.5,0.4 -2.8,0.6 -4,0.6 -1.1,0 -2.2,-0.2 -3.3,-0.5 -0.9,-0.3 -1.7,-0.7 -2.4,-1.2 -0.6,-0.5 -1,-0.9 -1.1,-1 -0.1,-0.3 -0.3,-1.4 -0.5,-3.5 -0.2,-2.3 0,-4.4 0.5,-6.3 0.7,-2.6 1.6,-5.3 2.7,-8.1 1.3,-3.1 1.9,-4.2 2,-4.4 1.7,-2.3 2.7,-4.8 3,-7.3 0.4,-3 -0.1,-5.8 -1.5,-8.3 -1.9,-3.9 -5.7,-6.1 -9.9,-6.1 z"
															id="path75"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g89">
																		<g
															id="g87">
																			<g
															id="g85">
																				<path
															class="st3"
															d="m 236.6,161.4 c -2.7,0 -6,-1.7 -6.9,-6.3 -0.4,-1.8 -0.4,-4.5 -0.3,-8.7 0.1,-3.6 0.3,-10.6 0.4,-20.8 0.1,-10.3 0.3,-17.4 0.6,-21 0.2,-3.4 0.4,-13.2 0.6,-29 0.2,-26.5 0.8,-27 3.1,-28.9 1.3,-1.1 2.9,-1.7 4.7,-1.7 1.2,0 2.5,0.3 3.7,0.8 1.7,0.7 5.5,3.1 4.7,9.6 -0.1,1 -0.4,5.6 -0.7,24.5 -0.2,8.6 -0.2,14.5 -0.2,18.4 1.9,-0.8 4.2,-1.5 6.8,-2.2 3.4,-0.8 6.2,-1.3 8.4,-1.5 0.4,0 0.8,0 1.2,0 2.3,0 4.7,0.4 7.1,1.3 2.3,0.8 4.2,1.5 5.8,2.2 2,0.8 3.8,1.8 5.3,3 2,1.5 3.5,3.9 4.8,7.1 0.9,2.3 1.7,4.4 2.5,6.3 1,2.4 1.6,5.1 1.9,8.2 0.3,2.6 0.5,5.1 0.6,7.3 0.1,2.4 0.1,4.8 0,7.2 -0.2,3.1 -1.1,5.9 -2.6,8.3 l -3.1,4.6 c -1.4,2.1 -3.6,4.2 -6.5,6.1 -3,2 -5.6,3.1 -7.9,3.5 -1.5,0.3 -3.6,0.6 -6.4,1 -2.3,0.3 -4.2,0.5 -5.9,0.5 -0.6,0 -1.2,0 -1.8,-0.1 -2.4,-0.2 -4.9,-1 -7.5,-2.4 -1.7,-0.9 -3.3,-2 -4.8,-3.4 -0.2,0.5 -0.3,1 -0.5,1.4 -1.7,3 -4.2,4.7 -7.1,4.7 z m 22.9,-49.8 c -1.4,0 -2.9,0.1 -4.4,0.3 -0.7,0.1 -1.3,0.4 -1.9,0.9 -1.4,1.3 -2.2,2.2 -2.6,2.7 -0.1,0.2 -0.8,1.2 -2.4,4.8 -1,2.3 -1.6,4.4 -1.7,6.3 -0.1,2 0.1,3.9 0.6,5.8 0.5,1.9 1.4,3.8 2.6,5.7 1.2,1.9 2.4,3.4 3.7,4.4 1.2,1 2.6,1.7 4.1,2.1 0.7,0.2 1.4,0.3 2.1,0.3 0.5,0 1.1,-0.1 1.6,-0.2 1.9,-0.5 3.8,-1 5.7,-1.7 1.5,-0.6 2.7,-1.2 3.5,-1.8 1.3,-1 2.6,-2 3.9,-2.9 0,-0.1 0.1,-0.4 0.2,-0.9 0.2,-2 0.3,-4.8 0.3,-8.6 0,-3.3 -0.5,-6.4 -1.4,-9.1 -0.7,-2.1 -2.3,-4.2 -4.8,-6.3 -1.6,-0.7 -2.8,-1.3 -3.7,-1.9 -0.1,0 -0.4,0 -0.7,0 z"
															id="path81"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																				<path
															class="st2"
															d="m 238.7,49 c 0.6,0 1.3,0.1 2.2,0.5 1.3,0.6 2.7,1.9 2.3,5.4 -0.2,2 -0.5,10.4 -0.8,24.9 -0.3,14.5 -0.3,23.2 -0.2,25.9 1.2,-1.3 2.5,-2.3 4.2,-3.1 1.9,-0.9 4.4,-1.8 7.6,-2.6 3.1,-0.8 5.7,-1.2 7.7,-1.4 0.3,0 0.6,0 0.9,0 1.8,0 3.8,0.4 5.8,1.1 2.2,0.8 4.1,1.5 5.6,2.1 1.7,0.7 3.1,1.5 4.4,2.5 1.4,1.1 2.5,2.9 3.5,5.4 0.9,2.3 1.7,4.4 2.5,6.3 0.8,2 1.4,4.4 1.6,7.1 0.3,2.6 0.5,5 0.6,7.2 0.1,2.2 0.1,4.5 0,6.7 -0.1,2.4 -0.8,4.6 -2,6.3 l -3.1,4.6 c -1.1,1.7 -2.9,3.4 -5.4,5 -2.5,1.7 -4.6,2.6 -6.3,2.9 -1.5,0.3 -3.6,0.6 -6.4,1 -2.1,0.3 -3.9,0.4 -5.4,0.4 -0.5,0 -1,0 -1.5,-0.1 -1.9,-0.1 -3.9,-0.8 -6,-1.9 -2.1,-1.1 -3.9,-2.6 -5.6,-4.3 l -4.3,-4.7 c -0.1,6.3 -0.5,8 -0.9,8.8 -1,2 -2.3,2.4 -3.3,2.4 -0.9,0 -2.5,-0.4 -3,-3.1 -0.3,-1.4 -0.4,-4 -0.2,-7.8 0.1,-3.7 0.3,-10.7 0.4,-20.9 0.1,-10.2 0.3,-17.2 0.6,-20.8 0.3,-3.5 0.4,-13.4 0.6,-29.2 0.2,-24.6 0.9,-25.2 1.6,-25.9 0.6,-0.4 1.3,-0.7 2.3,-0.7 m 20.9,100 c 0.9,0 1.7,-0.1 2.5,-0.3 2.1,-0.5 4.2,-1.1 6.1,-1.9 1.9,-0.7 3.4,-1.5 4.6,-2.5 1.3,-1 2.6,-2 3.9,-2.9 0.9,-0.6 1.5,-1.8 1.7,-3.5 0.2,-2.1 0.4,-5.2 0.4,-9 0,-3.8 -0.6,-7.3 -1.6,-10.4 -1,-3 -3.2,-5.8 -6.4,-8.4 -1.8,-0.8 -3.1,-1.4 -3.9,-2 -0.4,-0.2 -1.1,-0.5 -2.6,-0.5 h -4.8 c -1.6,0 -3.2,0.1 -5,0.4 -1.5,0.2 -2.8,0.8 -4,1.9 -1.3,1.2 -2.4,2.3 -3.1,3.2 -0.5,0.6 -1.4,2.1 -2.9,5.6 -1.2,2.8 -1.9,5.4 -2,7.7 -0.1,2.4 0.1,4.8 0.7,7 0.6,2.3 1.6,4.6 3.1,6.9 1.4,2.3 3,4.1 4.6,5.4 1.6,1.3 3.5,2.2 5.4,2.8 1.2,0.3 2.3,0.5 3.3,0.5 M 238.7,41 c -2.7,0 -5.2,0.9 -7.2,2.6 -3,2.6 -3.5,5.7 -3.9,9.4 -0.3,3.9 -0.5,11.1 -0.6,22.6 -0.2,19.6 -0.4,26.4 -0.6,28.7 -0.3,3.7 -0.5,10.9 -0.6,21.3 -0.1,10.1 -0.3,17.1 -0.4,20.7 -0.2,4.7 -0.1,7.6 0.4,9.7 1.4,7 6.7,9.6 10.8,9.6 3.3,0 6.4,-1.5 8.6,-4 0.6,0.3 1.1,0.7 1.7,1 3.1,1.6 6.1,2.6 9.1,2.8 0.7,0.1 1.4,0.1 2.1,0.1 1.9,0 4,-0.2 6.5,-0.5 2.8,-0.4 5,-0.7 6.5,-1 2.9,-0.5 5.9,-1.8 9.5,-4.1 3.3,-2.2 5.9,-4.7 7.6,-7.2 l 3.1,-4.6 c 2,-3 3.1,-6.4 3.3,-10.3 0.1,-2.5 0.1,-5.1 0,-7.6 -0.1,-2.3 -0.3,-4.8 -0.6,-7.5 -0.3,-3.4 -1.1,-6.6 -2.2,-9.3 -0.8,-1.9 -1.6,-4 -2.5,-6.2 -1.5,-4 -3.5,-6.9 -6.1,-8.8 -1.8,-1.4 -3.9,-2.6 -6.2,-3.6 -1.7,-0.7 -3.7,-1.5 -6,-2.3 -2.9,-1 -5.7,-1.5 -8.5,-1.5 -0.5,0 -1,0 -1.4,0 -2.5,0.2 -5.5,0.7 -9.1,1.6 -0.6,0.2 -1.2,0.3 -1.8,0.5 0,-3.4 0.1,-7.5 0.2,-12.8 0.3,-19.9 0.6,-23.5 0.7,-24.1 0.6,-4.9 -0.9,-11.1 -7,-13.7 -1.9,-1.1 -3.7,-1.5 -5.4,-1.5 z m 17.1,74.8 c 1.3,-0.2 2.5,-0.3 3.6,-0.3 h 4.3 c 0.8,0.4 1.7,0.9 2.7,1.3 1.6,1.4 2.7,2.8 3.1,4.1 0.8,2.3 1.2,4.9 1.2,7.8 0,3.5 -0.1,5.8 -0.2,7.2 -0.9,0.7 -1.8,1.4 -2.7,2.1 -0.2,0.2 -0.9,0.6 -2.4,1.2 -1.7,0.6 -3.4,1.2 -5.2,1.6 -0.2,0.1 -0.5,0.1 -0.7,0.1 -0.3,0 -0.6,0 -0.9,-0.1 -1,-0.3 -1.9,-0.8 -2.8,-1.4 -0.6,-0.5 -1.6,-1.5 -2.8,-3.4 -1,-1.6 -1.7,-3.2 -2.1,-4.6 -0.4,-1.5 -0.5,-3 -0.5,-4.6 0.1,-1.4 0.5,-3.1 1.3,-4.9 1.3,-2.9 1.9,-3.9 2,-4.1 0.4,-0.2 0.9,-0.9 2.1,-2 z"
															id="path83"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																			</g>
																		</g>
																	</g>
																	<g
															id="g97">
																		<g
															id="g95">
																			<path
															class="st3"
															d="m 352.5,161.5 c -2.9,0 -5.4,-1.7 -6.8,-4.6 -0.2,-0.4 -0.4,-0.8 -0.5,-1.4 -1.5,1.3 -3.1,2.4 -4.8,3.4 -2.6,1.4 -5.1,2.2 -7.5,2.4 -0.6,0 -1.2,0.1 -1.8,0.1 -1.7,0 -3.6,-0.2 -5.9,-0.5 -2.7,-0.4 -4.9,-0.7 -6.5,-1 -2.3,-0.4 -4.9,-1.5 -7.9,-3.5 -2.9,-1.9 -5.1,-4 -6.5,-6.1 l -3.1,-4.6 c -1.6,-2.3 -2.5,-5.1 -2.6,-8.3 -0.1,-2.4 -0.1,-4.8 0,-7.2 0.1,-2.2 0.3,-4.7 0.6,-7.3 0.3,-3.1 0.9,-5.8 1.9,-8.2 0.8,-1.9 1.6,-4 2.5,-6.3 1.3,-3.3 2.8,-5.6 4.8,-7.1 1.5,-1.2 3.3,-2.2 5.3,-3 1.6,-0.7 3.6,-1.4 5.8,-2.2 2.4,-0.9 4.8,-1.3 7.1,-1.3 0.4,0 0.8,0 1.2,0 2.2,0.2 5.1,0.7 8.4,1.5 2.2,0.6 4.2,1.1 5.8,1.8 0.1,-0.6 0.3,-1.2 0.5,-1.8 1.1,-2.9 3.5,-4.9 6.6,-5.3 0.3,0 0.7,-0.1 1,-0.1 3.1,0 5.7,1.8 7,4.8 0.8,1.8 1.3,4.5 1.6,8.9 0.3,3.7 0.5,10.8 0.6,21 0.1,10.3 0.3,17.1 0.4,20.8 0.1,4.3 0.1,7 -0.3,8.7 -0.9,4.7 -4.2,6.4 -6.9,6.4 z m -37.7,-23.1 c 1.3,0.9 2.6,1.9 3.9,2.9 0.8,0.6 2,1.3 3.5,1.8 1.8,0.7 3.7,1.3 5.7,1.7 0.5,0.1 1.1,0.2 1.6,0.2 v 0 c 0.7,0 1.4,-0.1 2.1,-0.3 1.5,-0.4 2.9,-1.1 4.1,-2.1 1.3,-1 2.5,-2.5 3.7,-4.4 1.2,-1.9 2.1,-3.9 2.6,-5.7 0.5,-1.9 0.7,-3.8 0.6,-5.8 -0.1,-1.9 -0.7,-4 -1.7,-6.3 -1.6,-3.6 -2.3,-4.7 -2.4,-4.8 -0.4,-0.5 -1.1,-1.4 -2.6,-2.7 -0.6,-0.5 -1.2,-0.8 -1.9,-0.9 -1.5,-0.2 -3,-0.3 -4.4,-0.3 h -4.8 c -0.3,0 -0.6,0 -0.7,0 -0.9,0.6 -2.1,1.2 -3.7,1.9 -2.4,2 -4,4.1 -4.8,6.3 -0.9,2.7 -1.4,5.8 -1.4,9.1 0,3.7 0.1,6.6 0.3,8.6 0.2,0.4 0.3,0.7 0.3,0.8 z"
															id="path91"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																			<path
															class="st2"
															d="m 350.1,94.9 c 1.5,0 2.7,0.9 3.4,2.4 0.6,1.3 1,3.8 1.3,7.6 0.3,3.6 0.5,10.6 0.6,20.8 0.1,10.4 0.3,17.2 0.4,20.9 0.1,3.9 0.1,6.4 -0.2,7.8 -0.5,2.7 -2.1,3.1 -3,3.1 -0.9,0 -2.3,-0.4 -3.3,-2.4 -0.4,-0.8 -0.8,-2.5 -0.9,-8.8 l -4.3,4.7 c -1.6,1.8 -3.5,3.2 -5.6,4.3 -2.1,1.1 -4.1,1.8 -6,1.9 -0.5,0 -1,0.1 -1.5,0.1 -1.5,0 -3.3,-0.1 -5.4,-0.4 -2.7,-0.4 -4.8,-0.7 -6.4,-1 -1.8,-0.3 -3.8,-1.2 -6.3,-2.9 -2.5,-1.6 -4.3,-3.3 -5.4,-5 l -3.1,-4.6 c -1.2,-1.8 -1.8,-3.9 -2,-6.3 -0.1,-2.2 -0.1,-4.5 0,-6.7 0.1,-2.2 0.3,-4.6 0.6,-7.2 0.3,-2.7 0.8,-5.1 1.6,-7.1 0.8,-1.9 1.6,-4 2.5,-6.3 1,-2.6 2.2,-4.4 3.5,-5.4 1.3,-1 2.7,-1.8 4.4,-2.5 1.6,-0.7 3.5,-1.4 5.6,-2.1 2,-0.7 4,-1.1 5.8,-1.1 0.3,0 0.6,0 0.9,0 2,0.1 4.6,0.6 7.7,1.4 3.2,0.8 5.7,1.7 7.6,2.6 1.2,0.6 2.4,1.4 3.3,2.3 -0.1,-1.2 -0.2,-2.2 -0.3,-3.1 -0.1,-1.6 0,-3.1 0.5,-4.3 0.6,-1.5 1.8,-2.5 3.3,-2.7 0.4,0 0.5,0 0.7,0 m -20.6,54.2 c 1.1,0 2.1,-0.2 3.2,-0.5 2,-0.6 3.8,-1.5 5.4,-2.8 1.6,-1.3 3.2,-3.1 4.6,-5.4 1.4,-2.3 2.5,-4.6 3.1,-6.9 0.6,-2.3 0.8,-4.6 0.7,-7 -0.1,-2.4 -0.8,-5 -2,-7.7 -1.5,-3.5 -2.4,-5 -2.9,-5.6 -0.7,-0.9 -1.7,-2 -3.1,-3.2 -1.2,-1.1 -2.5,-1.7 -4,-1.9 -1.7,-0.2 -3.4,-0.4 -5,-0.4 h -4.8 c -1.5,0 -2.3,0.3 -2.6,0.5 -0.8,0.5 -2.1,1.2 -3.9,2 -3.2,2.6 -5.4,5.4 -6.5,8.4 -1.1,3.1 -1.6,6.7 -1.6,10.4 0,3.9 0.1,6.9 0.4,9 0.2,1.7 0.8,2.9 1.7,3.5 1.3,0.9 2.6,1.9 3.9,2.9 1.1,0.9 2.7,1.7 4.6,2.5 2,0.7 4,1.4 6.1,1.9 1,0.2 1.9,0.3 2.7,0.3 m 20.6,-62.2 c -0.5,0 -1,0 -1.5,0.1 -3.9,0.5 -7.1,2.7 -9,6 -0.8,-0.2 -1.6,-0.4 -2.5,-0.7 -3.6,-0.9 -6.6,-1.4 -9.1,-1.6 -0.5,0 -1,0 -1.5,0 -2.8,0 -5.6,0.5 -8.5,1.5 -2.3,0.8 -4.4,1.6 -6,2.3 -2.3,1 -4.4,2.2 -6.2,3.6 -2.6,2 -4.5,4.9 -6.1,8.8 -0.9,2.3 -1.7,4.4 -2.5,6.2 -1.1,2.7 -1.8,5.9 -2.2,9.3 -0.3,2.7 -0.5,5.2 -0.6,7.5 -0.1,2.5 -0.1,5.1 0,7.6 0.2,3.9 1.3,7.3 3.3,10.3 l 3.1,4.6 c 1.7,2.6 4.3,5 7.6,7.2 3.5,2.3 6.5,3.7 9.5,4.1 1.6,0.3 3.8,0.6 6.5,1 2.5,0.4 4.6,0.5 6.5,0.5 0.7,0 1.4,0 2.1,-0.1 3,-0.2 6,-1.2 9.1,-2.8 0.6,-0.3 1.1,-0.6 1.7,-1 2.2,2.6 5.2,4 8.6,4 4.1,0 9.4,-2.5 10.8,-9.5 0.4,-2.1 0.5,-5 0.4,-9.7 -0.1,-3.6 -0.2,-10.4 -0.4,-20.7 -0.1,-10.3 -0.3,-17.5 -0.6,-21.3 -0.4,-5 -0.9,-8 -1.9,-10.3 -1.9,-4.2 -6,-6.9 -10.6,-6.9 z m -24.8,28.8 h 4.3 c 1.1,0 2.4,0.1 3.6,0.3 1.2,1.1 1.8,1.8 2,2 0.1,0.2 0.7,1.1 2,4.1 0.8,1.8 1.3,3.5 1.3,4.9 0.1,1.6 -0.1,3.1 -0.5,4.6 -0.4,1.5 -1.1,3 -2.1,4.6 -1.2,1.9 -2.2,2.9 -2.8,3.4 -0.8,0.7 -1.8,1.1 -2.8,1.4 -0.3,0.1 -0.6,0.1 -0.9,0.1 -0.2,0 -0.5,0 -0.7,-0.1 -1.8,-0.4 -3.5,-0.9 -5.2,-1.6 -1.5,-0.6 -2.2,-1 -2.4,-1.2 -0.9,-0.7 -1.8,-1.4 -2.7,-2.1 -0.1,-1.4 -0.2,-3.6 -0.2,-7.2 0,-2.9 0.4,-5.5 1.2,-7.8 0.5,-1.3 1.5,-2.7 3.1,-4.1 1.2,-0.5 2.1,-0.9 2.8,-1.3 z"
															id="path93"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g105">
																		<g
															id="g103">
																			<path
															class="st3"
															d="m 377.3,160 c -1.5,0 -3.1,-0.3 -4.8,-1 -4.3,-1.8 -5.5,-4.6 -5.8,-6.6 -0.2,-1.6 -0.1,-3.2 0.3,-5 0.7,-3.1 3,-5.4 6.9,-6.8 l 2,-0.8 c 0.5,-0.2 0.9,-0.3 1.4,-0.3 0.8,0 1.6,0.2 2.3,0.7 0.4,0.3 0.8,0.7 1.1,1.1 0.8,0.4 1.7,0.9 2.8,1.6 2,1.4 3.3,3.4 3.9,5.6 0.7,2.7 0.1,5.4 -1.7,7.5 -1.3,1.6 -3,2.7 -5.2,3.4 -1,0.4 -2.1,0.6 -3.2,0.6 z"
															id="path99"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																			<path
															class="st2"
															d="m 377.3,143.5 v 1.1 c 0.4,0 0.8,0.1 1.2,0.2 0.7,0.2 1.5,0.6 2.6,1.4 1.2,0.9 2,2 2.3,3.3 0.4,1.5 0.1,2.9 -0.9,4 -0.8,1 -2,1.7 -3.4,2.2 -0.6,0.2 -1.2,0.3 -1.8,0.3 -1,0 -2.1,-0.2 -3.2,-0.7 -2,-0.9 -3.2,-2 -3.4,-3.5 -0.2,-1.1 -0.1,-2.3 0.2,-3.6 0.4,-1.7 1.8,-3 4.4,-4 l 2,-0.7 m 0,-8 c -0.9,0 -1.9,0.2 -2.8,0.5 l -2,0.8 c -6.5,2.4 -8.7,6.6 -9.4,9.7 -0.5,2.2 -0.6,4.4 -0.3,6.5 0.4,2.5 1.9,7.1 8.2,9.7 2.1,0.9 4.2,1.3 6.3,1.3 1.5,0 3,-0.2 4.4,-0.7 2.8,-0.9 5.2,-2.5 7,-4.7 2.6,-3.1 3.5,-7.1 2.5,-11.1 -0.8,-3.2 -2.7,-6 -5.4,-7.9 -0.9,-0.6 -1.7,-1.2 -2.5,-1.6 -0.4,-0.4 -0.8,-0.8 -1.3,-1.2 -1.5,-0.8 -3.1,-1.3 -4.7,-1.3 z"
															id="path101"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g113">
																		<g
															id="g111">
																			<path
															class="st3"
															d="m 411,150.8 c -1.4,0 -2.8,-0.4 -4.1,-1.2 -1.8,-1 -3.9,-3.1 -4.3,-7.4 -0.1,-1.5 -1.2,-14.7 -3.2,-39.5 -0.6,-1.7 -0.8,-3.4 -0.8,-5.2 0,-2 0.3,-3.7 1.1,-5.1 l -0.3,-0.1 c -0.6,-0.3 -1.2,-0.7 -1.6,-1.2 l -0.2,-0.3 c -1.1,-1.4 -2,-2.6 -2.6,-3.4 -0.6,-0.9 -1.2,-1.9 -1.7,-2.9 -0.8,-1.5 -1.2,-3.3 -1.2,-5.1 0,-1.2 0.1,-2.5 0.2,-3.9 0.2,-1.7 0.6,-3.2 1.2,-4.6 0.8,-1.9 2.3,-3.6 4.3,-4.8 1.9,-1.2 4,-1.8 6.3,-1.8 1.8,0 3.6,0.4 5.6,1.1 2.7,1 4.8,2.8 6.2,5.4 1.1,2.1 1.8,4.5 2,7 0.2,2.7 -0.3,5.5 -1.6,8.3 -0.9,2.1 -2,3.7 -3.3,4.9 0.7,1.1 1.3,2.4 1.6,4.1 0.2,1.1 0.6,4.9 2.3,23.9 2,21.6 1.8,23.1 1.7,24 -0.4,3.9 -2.3,5.7 -3.8,6.7 -1.2,0.8 -2.5,1.1 -3.8,1.1 z"
															id="path107"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																			<path
															class="st2"
															d="m 404,68.3 c 1.3,0 2.7,0.3 4.3,0.9 1.8,0.6 3.1,1.8 4.1,3.6 0.9,1.6 1.4,3.4 1.5,5.4 0.1,2 -0.3,4.2 -1.3,6.5 -1.1,2.5 -2.3,3.9 -3.7,4.4 -1.2,0.4 -2.4,0.7 -3.6,0.7 -1.2,0 -2.6,-0.3 -4,-0.9 l -0.4,-0.1 -0.2,-0.3 c -1,-1.3 -1.8,-2.4 -2.4,-3.2 -0.5,-0.8 -1,-1.6 -1.4,-2.5 -0.5,-1 -0.7,-2.1 -0.7,-3.4 0,-1.1 0.1,-2.2 0.2,-3.4 0.1,-1.3 0.4,-2.5 0.9,-3.5 0.5,-1.2 1.4,-2.2 2.7,-3 1.1,-0.9 2.5,-1.2 4,-1.2 m 1.3,14.1 c 0.3,0 0.6,-0.1 0.9,-0.2 v 0 c 0,0 0.3,-0.2 0.8,-1.3 0.4,-0.9 0.5,-1.6 0.5,-2.3 -0.1,-0.8 -0.3,-1.5 -0.6,-2.1 -0.2,-0.4 -0.5,-0.7 -0.9,-0.8 -0.5,-0.2 -0.9,-0.3 -1.3,-0.3 -0.3,0 -0.6,0.1 -0.9,0.3 -0.3,0.2 -0.4,0.4 -0.5,0.6 -0.1,0.3 -0.2,0.7 -0.2,1.1 0,0.6 0,1.1 0,1.7 0,0.4 0,0.8 0.1,1 0.1,0.3 0.2,0.6 0.4,0.9 0.1,0.2 0.4,0.6 1,1.3 0.1,0.1 0.4,0.1 0.7,0.1 m 1.8,9.6 c 1.1,0 2.9,0.5 3.4,3.8 0.3,1.7 1,9.5 2.3,23.7 1.7,19 1.8,22.4 1.7,23.3 -0.2,1.8 -0.8,3 -1.9,3.6 -0.4,0.2 -1,0.5 -1.7,0.5 -0.6,0 -1.3,-0.2 -2.2,-0.6 -1.3,-0.8 -2.1,-2.2 -2.3,-4.2 -0.1,-1.5 -1.2,-14.9 -3.2,-40 -0.5,-1.4 -0.8,-2.8 -0.8,-4.4 0,-1.8 0.4,-3.1 1.1,-4 0.7,-0.9 1.8,-1.7 3.6,-1.7 M 404,60.3 c -3,0 -5.8,0.8 -8.4,2.4 -2.7,1.7 -4.7,3.9 -5.8,6.6 -0.8,1.8 -1.2,3.7 -1.5,5.8 -0.2,1.5 -0.2,2.9 -0.2,4.3 0,2.5 0.5,4.8 1.6,6.9 0.6,1.1 1.2,2.2 1.9,3.3 0.7,1 1.6,2.2 2.8,3.7 l 0.2,0.3 c 0.1,0.1 0.2,0.3 0.3,0.4 -0.2,1.1 -0.3,2.3 -0.3,3.5 0,2.1 0.3,4.1 0.9,6 2,24.2 3,37.5 3.2,39.1 0.5,6.3 4.2,9.3 6.3,10.5 2,1.1 4,1.7 6.1,1.7 2,0 4,-0.6 5.8,-1.6 1.9,-1.1 5.1,-3.9 5.7,-9.7 0.1,-1.3 0.3,-2.8 -1.7,-24.8 -1.7,-18.9 -2.2,-22.9 -2.4,-24.2 -0.2,-1 -0.4,-2 -0.8,-2.9 0.8,-1.1 1.5,-2.4 2.2,-3.9 1.5,-3.5 2.2,-6.9 1.9,-10.2 -0.2,-3.2 -1.1,-6.1 -2.5,-8.7 -1.9,-3.4 -4.8,-5.9 -8.3,-7.3 -2.5,-0.8 -4.8,-1.2 -7,-1.2 z"
															id="path109"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																	<g
															id="g121">
																		<g
															id="g119">
																			<path
															class="st3"
															d="m 451.8,160 c -2.7,0 -5.1,-1.5 -6.7,-4.2 -1.2,-2 -1.6,-4.8 -1.4,-9 0.1,-1.9 0.2,-8.2 -0.1,-26.7 -0.1,-8.7 -0.2,-15.2 -0.3,-19.3 -0.5,0 -1.1,0.1 -1.8,0.2 -4.3,0.4 -7.3,0.7 -9.3,0.7 -0.7,0 -1.4,0 -1.9,-0.1 -5.2,-0.6 -7,-4.1 -7,-6.9 0,-2.8 1.5,-5.3 4.2,-6.9 1.2,-0.7 2.3,-1.4 16.2,-2.4 -0.2,-5.3 -0.4,-10.5 -0.5,-15.7 -0.1,-10.8 0.8,-13.7 2.8,-15.6 2.2,-2.2 4.5,-2.7 6.1,-2.7 0.4,0 0.8,0 1.1,0.1 5.6,0.8 6.2,7.3 6.4,9.8 0.3,3.2 0.5,8.4 0.6,15.7 0.1,3.1 0.1,5.3 0.2,6.9 2.9,-0.2 5.1,-0.3 6.8,-0.4 0.2,0 0.4,0 0.6,0 4,0 6.2,1.7 7.3,3 1.8,2.2 2.8,6.1 -0.4,9.8 -2,2.3 -5,3.4 -9.3,3.4 -1.7,0 -3.4,0 -4.9,0.1 0,3 -0.1,7.7 -0.2,14.5 -0.1,11.3 -0.1,20.2 0.2,26.4 0.4,9.1 -0.4,12.4 -1.6,14.5 -2,3.2 -4.4,4.8 -7.1,4.8 z"
															id="path115"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
																			<path
															class="st2"
															d="m 452,55.4 c 0.2,0 0.4,0 0.6,0 2.2,0.3 2.7,3.3 3,6.2 0.3,3.1 0.5,8.2 0.6,15.4 0.1,7.3 0.3,9.9 0.4,10.8 0.3,0.1 0.8,0.1 1.7,0.1 0.5,0 1.1,0 1.8,-0.1 3,-0.2 5.4,-0.3 7.1,-0.4 0.1,0 0.3,0 0.4,0 1.9,0 3.4,0.5 4.2,1.6 0.5,0.6 1.6,2.4 -0.4,4.6 -1.2,1.3 -3.2,2 -6.3,2 -2.5,0 -4.9,0.1 -7,0.2 -1.1,0.1 -1.6,0.2 -1.9,0.3 0,1.6 -0.1,7.3 -0.2,18 -0.1,11.4 -0.1,20.3 0.2,26.6 0.4,8.7 -0.4,11.2 -1.1,12.3 -0.7,1.2 -1.9,2.8 -3.6,2.8 -0.9,0 -2.1,-0.4 -3.2,-2.2 -0.7,-1.3 -1,-3.4 -0.8,-6.8 0.2,-2.9 0.1,-12 -0.1,-27 -0.2,-12.6 -0.3,-20.7 -0.3,-23.2 -0.3,0 -0.8,-0.1 -1.5,-0.1 -1,0 -2.5,0.1 -4.7,0.3 -4.1,0.4 -7,0.6 -8.9,0.6 -0.6,0 -1.1,0 -1.4,-0.1 -3.1,-0.4 -3.4,-2.2 -3.4,-3 0,-1 0.4,-2.3 2.2,-3.4 0.6,-0.4 1.7,-1 18.3,-2.2 -0.3,-6.5 -0.5,-13 -0.6,-19.4 v 0 c -0.2,-10.1 0.7,-11.8 1.5,-12.6 1.4,-1 2.5,-1.3 3.4,-1.3 m 0,-8 c -3.3,0 -6.4,1.4 -8.9,3.9 -3.2,3.2 -4,7.3 -3.8,18.4 0.1,3.9 0.2,7.9 0.3,11.9 -11.1,1 -12.3,1.6 -14,2.7 -4,2.3 -6.2,6.1 -6.2,10.3 0,2.4 0.8,4.7 2.3,6.6 1.3,1.7 3.9,3.8 8.3,4.3 0.7,0.1 1.4,0.1 2.3,0.1 1.7,0 4,-0.1 7.2,-0.4 0.1,3.9 0.1,8.9 0.2,14.9 0.3,18.4 0.2,24.5 0.1,26.4 -0.3,5 0.3,8.5 1.9,11.2 2.3,4 6,6.2 10.1,6.2 3,0 7.2,-1.2 10.5,-6.8 1.9,-3.3 2.5,-7.8 2.2,-16.7 -0.2,-6.1 -0.3,-14.9 -0.2,-26.1 0,-4.3 0.1,-7.9 0.1,-10.6 0.3,0 0.6,0 1,0 5.4,0 9.6,-1.6 12.3,-4.7 4.6,-5.2 3.5,-11.3 0.5,-15 -1.7,-2 -4.9,-4.5 -10.4,-4.5 -0.2,0 -0.5,0 -0.7,0 -0.8,0 -1.7,0.1 -2.7,0.1 0,-0.8 0,-1.7 -0.1,-2.7 -0.1,-7.6 -0.3,-12.7 -0.7,-16 -0.2,-1.8 -0.5,-4 -1.3,-6.2 -1.5,-4 -4.6,-6.6 -8.5,-7.1 -0.6,-0.2 -1.2,-0.2 -1.8,-0.2 z"
															id="path117"
															inkscape:connector-curvature="0"
															style="fill:#e35205" />
																		</g>
																	</g>
																</g>
															</g>
															<g
															id="g146"
															transform="translate(-34.723458,-61.842024)">

																	<circle
															transform="matrix(0.4927,-0.8702,0.8702,0.4927,-54.93,131.9336)"
															class="st4"
															cx="85.699997"
															cy="113.1"
															id="ellipse126"
															r="42.400002"
															style="fill:#e73d33" />
																<path
															class="st5"
															d="m 128.2,101.7 c -0.5,-2.8 -0.3,-4.9 -0.2,-7.7 0.1,-2.8 0.9,-10.1 -3.6,-14.9 -5.3,-5.5 -8.3,-7 -15.2,-6.2 -5,0.6 -6.1,0.6 -11.1,-2.3 -6,-3.6 0,-9.4 -11.3,-8.7 -4.7,0.3 -8,2.2 -11.1,4.5 -3.1,2.3 -5.2,5.1 -6.4,6 -0.9,0.7 -5.7,0.8 -10.9,5.1 -5.8,4.8 -7.5,9 -10.5,12.4 -2.8,3.2 -9.1,3.7 -11.9,10 -2.8,6.3 -0.6,17.5 2.8,20.7 2.5,2.3 4,3.4 4.7,4.9 0.7,1.5 -0.3,3.1 0.4,4.7 1,2.1 4.6,5.9 6.6,9 2,3.1 4.3,11.9 12.6,15.4 2.1,0.9 6.1,1.1 8.1,1.3 2,0.2 6.2,2 8.7,2.6 2.7,0.6 4.8,-0.8 7.5,-0.6 2.7,0.1 4.1,2.7 7.5,2.1 6.5,-1.1 13.4,-8.9 17.7,-10.9 2.8,-1.3 4.8,2.5 8.1,-2.3 2.9,-4.2 4.2,-12.4 6.8,-14.3 1.1,-0.9 2.5,-0.8 4.5,-1.5 2.6,-0.9 7.3,-2.3 7.9,-7.9 1.2,-12.1 -10.5,-14.7 -11.7,-21.4 z m -42.3,49.7 c -21.2,0 -38.3,-17.2 -38.3,-38.3 0,-21.2 17.2,-38.3 38.3,-38.3 21.2,0 38.3,17.2 38.3,38.3 0.1,21.2 -17.1,38.3 -38.3,38.3 z"
															id="path128"
															inkscape:connector-curvature="0"
															style="fill:#af1a19" />
																<g
															id="g140">
																	<path
															class="st6"
															d="m 262.7,102 h -15.8 l -2.6,14.2 c -1,5.1 -1.5,7.5 -4.3,7.5 -1.6,0 -2.5,-1 -2.5,-2.9 0,-1.2 0.3,-2.5 0.6,-4 l 2.7,-14.7 h -15 l 0.1,-0.5 c -1.6,-0.3 -2.9,-0.5 -4,-0.5 -4,0 -7.1,1.9 -9.5,5.8 l 1.2,-4.7 H 198.7 L 195,122.3 190.5,87.8 H 171 l -25.6,49 h 19.1 l 2.7,-6.5 H 179 l 0.3,6.5 h 12.8 4.6 11.7 l 2.8,-15.4 c 0.8,-4.6 2.1,-6.8 6.4,-6.8 1.2,0 2.7,0.3 4.3,0.8 -0.6,3.1 -1.1,5.7 -1.1,7.9 0,9.3 6.5,14.7 17.7,14.7 13.2,0 18.5,-6 21.1,-20.2 z m -90.6,16.5 3.4,-8.2 c 0.5,-1.4 1.4,-3.8 2.5,-7.1 -0.1,1.2 -0.1,2.4 -0.1,3.4 0,2.6 0.1,4.8 0.2,6.5 l 0.2,5.3 h -6.2 z"
															id="path130"
															inkscape:connector-curvature="0"
															style="fill:#979391" />
																	<path
															class="st6"
															d="m 327.3,107 c -2.3,-4.1 -5.4,-6.1 -9.8,-6.1 -4.9,0 -9.2,2.4 -12.6,7 -1.3,1.8 -2.4,3.8 -3.2,5.9 -0.9,-7.9 -6,-12.9 -12.6,-12.9 -3.9,0 -7.1,1.7 -9.9,5.1 0.9,-2 1.4,-3.5 1.6,-4.5 L 284,84.7 h -16.3 l -9.5,51.9 h 16.2 l 0.8,-4.1 c 2.1,3.6 5.2,5.3 9.3,5.3 4.9,0 9.2,-2.4 12.6,-7 1.3,-1.8 2.4,-3.8 3.2,-5.9 0.9,7.9 6,12.9 12.6,12.9 4.2,0 7.5,-1.9 10.4,-5.9 l -1.2,4.7 h 15.4 L 343.9,102 H 328 Z m -48,17.1 c -2.1,0 -3.4,-1.4 -3.4,-3.9 0,-3.2 2,-5.6 4.6,-5.6 2.3,0 3.8,1.6 3.8,4.2 -0.1,3 -2.2,5.3 -5,5.3 z m 40.6,0.3 c -2.3,0 -3.6,-1.4 -3.6,-3.9 0,-3.3 1.9,-5.6 4.5,-5.6 2.3,0 3.8,1.5 3.8,4.1 0.1,3.2 -1.9,5.4 -4.7,5.4 z"
															id="path132"
															inkscape:connector-curvature="0"
															style="fill:#979391" />
																	<path
															class="st6"
															d="m 406.5,103.5 c 0,-10.6 -7.2,-15.9 -21.7,-15.9 H 366 l -9,49 h 17.8 l 2.7,-15 h 7 c 14.3,0 22,-6.9 22,-18.1 z m -25.3,5.3 c -0.4,0 -0.8,0 -1.3,0 l 1.6,-8.4 c 0.3,0 0.5,0 0.8,0 4.5,0 6.5,1 6.5,3.6 0,3.3 -2.4,4.8 -7.6,4.8 z"
															id="path134"
															inkscape:connector-curvature="0"
															style="fill:#979391" />
																	<polygon
															class="st6"
															points="424.9,105.6 425.8,100.9 441.7,100.9 444.1,87.6 410.6,87.6 401.5,136.6 436.6,136.6 439.1,123.3 421.7,123.3 422.6,118 437.6,118 439.9,105.6 "
															id="polygon136"
															style="fill:#979391" />
																	<path
															class="st6"
															d="m 468.8,102.7 c 3.2,0 6.4,1 9.7,2.9 l 3,-16.4 c -3.7,-1.9 -7.8,-2.8 -12.5,-2.8 -8.9,0 -16.6,3.5 -21.8,9.6 -4.5,5.2 -6.7,11.7 -6.7,18.9 0,6.9 2.7,13.2 7.5,17.3 4.2,3.7 9.7,5.7 15.8,5.7 3,0 6,-0.5 9,-1.6 l 3.3,-17.7 c -3.2,2 -6.6,3 -9.3,3 -5.2,0 -8.6,-3.2 -8.6,-8.4 0,-6.1 4.4,-10.5 10.6,-10.5 z"
															id="path138"
															inkscape:connector-curvature="0"
															style="fill:#979391" />
																</g>
																<g
															id="g144">
																	<path
															class="st7"
															d="m 103.5,86.2 c 3.2,2.2 5.9,5.1 8.1,8.6 2.2,3.5 3.7,7.6 4.5,12.3 0.6,3.4 0.7,6.9 0.4,10.5 -0.3,3.7 -1,6.8 -2.1,9.3 l -18.4,3.3 -1.1,-2.7 c -1.2,1.2 -2.4,2.1 -3.6,2.9 -1.2,0.8 -3,1.4 -5.4,1.8 -3.9,0.7 -7.4,-0.4 -10.4,-3.2 -3,-2.8 -5,-7 -6,-12.5 -0.5,-2.9 -0.6,-5.6 -0.1,-7.9 0.4,-2.3 1.2,-4.5 2.3,-6.4 1.1,-1.8 2.4,-3.3 4.2,-4.5 1.7,-1.2 3.5,-2 5.4,-2.3 1.6,-0.3 3.1,-0.2 4.4,0.1 1.3,0.4 2.4,0.8 3.2,1.4 l -0.4,-2.2 8.4,-1.5 5.2,29.5 6.1,-1.1 c 0.5,-2.1 0.8,-4.2 0.8,-6.5 0,-2.3 -0.1,-4.5 -0.5,-6.5 -0.7,-4.1 -1.9,-7.5 -3.6,-10.4 -1.7,-2.9 -3.7,-5.1 -6,-6.8 -2.4,-1.7 -5.1,-2.8 -8,-3.4 -2.9,-0.5 -6,-0.5 -9.2,0.1 -3.1,0.5 -5.9,1.7 -8.4,3.3 -2.5,1.7 -4.7,3.7 -6.4,6.2 -1.8,2.5 -3.1,5.4 -3.8,8.8 -0.8,3.4 -0.8,7 -0.2,10.7 0.7,4.1 2,7.6 3.8,10.6 1.8,2.9 4,5.3 6.4,7 2.5,1.7 5.2,2.9 8.1,3.5 3,0.6 6,0.6 9.1,0.1 2,-0.4 4.3,-1 6.9,-1.8 2.5,-0.8 4.8,-1.7 6.7,-2.7 l 1.2,7 c -2.2,0.9 -4.3,1.7 -6.5,2.3 -2.2,0.7 -4.6,1.2 -7.2,1.7 -4.4,0.8 -8.6,0.7 -12.6,-0.1 -4,-0.9 -7.6,-2.4 -10.9,-4.8 -3.2,-2.3 -5.9,-5.3 -8.2,-8.9 -2.2,-3.7 -3.7,-7.8 -4.6,-12.5 -0.8,-4.5 -0.7,-8.8 0.2,-12.9 0.9,-4.1 2.5,-7.8 4.8,-11.2 2.2,-3.3 5.1,-6.1 8.6,-8.3 3.5,-2.3 7.4,-3.8 11.7,-4.6 4.2,-0.7 8.3,-0.7 12.3,0.1 4.1,0.9 7.6,2.4 10.8,4.6 z M 93,120.8 89.8,102.6 c -1.1,-0.3 -2.1,-0.5 -2.9,-0.6 -0.9,-0.1 -1.9,0 -2.9,0.2 -2.3,0.4 -3.9,1.7 -4.8,4 -0.9,2.2 -1,5.1 -0.4,8.6 0.7,3.8 1.7,6.5 3,8.2 1.4,1.6 3.2,2.3 5.6,1.8 1.3,-0.2 2.3,-0.7 3.2,-1.3 0.8,-0.7 1.6,-1.6 2.4,-2.7 z"
															id="path142"
															inkscape:connector-curvature="0"
															style="fill:#a01a19" />
																</g>
															</g>
														</svg>

													</div>
													<div class="logoAruba">
														<svg
														xmlns:dc="http://purl.org/dc/elements/1.1/"
														xmlns:cc="http://creativecommons.org/ns#"
														xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
														xmlns:svg="http://www.w3.org/2000/svg"
														xmlns="http://www.w3.org/2000/svg"
														xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
														xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
														viewBox="0 0 429.9585 120.40045"
														version="1.1"
														id="svg56"
														sodipodi:docname="aruba-logo.svg"
														width="429.9585"
														height="120.40045"
														inkscape:version="0.92.3 (2405546, 2018-03-11)">
														<metadata
															id="metadata62">
															<rdf:RDF>
															<cc:Work
																rdf:about="">
																<dc:format>image/svg+xml</dc:format>
																<dc:type
																rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
																<dc:title></dc:title>
															</cc:Work>
															</rdf:RDF>
														</metadata>
														<defs
															id="defs60" />
														<sodipodi:namedview
															pagecolor="#ffffff"
															bordercolor="#666666"
															borderopacity="1"
															objecttolerance="10"
															gridtolerance="10"
															guidetolerance="10"
															inkscape:pageopacity="0"
															inkscape:pageshadow="2"
															inkscape:window-width="1920"
															inkscape:window-height="1051"
															id="namedview58"
															showgrid="false"
															inkscape:zoom="1.0583239"
															inkscape:cx="99.580869"
															inkscape:cy="18.355002"
															inkscape:window-x="-9"
															inkscape:window-y="-9"
															inkscape:window-maximized="1"
															inkscape:current-layer="svg56" />
														<path
															d="m 53.832493,44.35045 a 10.66,10.66 0 0 0 -1.38,0.09 11.47,11.47 0 0 0 -8.73,5.85 c -0.76,-0.22 -1.55,-0.44 -2.39,-0.64 a 51.19,51.19 0 0 0 -8.83,-1.55 c -0.46,0 -0.94,-0.05 -1.42,-0.05 a 24.57,24.57 0 0 0 -8.18,1.47 c -2.24,0.79 -4.2,1.54 -5.85,2.22 a 25.86,25.86 0 0 0 -6,3.46 19.26,19.26 0 0 0 -5.8899998,8.55 q -1.28,3.28 -2.37,6 a 33,33 0 0 0 -2.08999995,9 c -0.28,2.58 -0.46,5.01 -0.59,7.25 a 60.74,60.74 0 0 0 0,7.39 19.62,19.62 0 0 0 3.19999995,9.92 l 3,4.45 a 26,26 0 0 0 7.3599998,7 23.44,23.44 0 0 0 9.15,4 c 1.53,0.26 3.66,0.58 6.32,1 a 45.28,45.28 0 0 0 6.29,0.51 c 0.7,0 1.38,0 2,-0.07 a 22.47,22.47 0 0 0 8.8,-2.72 c 0.56,-0.3 1.11,-0.62 1.64,-1 a 10.85,10.85 0 0 0 8.3,3.89 c 4,0 9.13,-2.42 10.49,-9.24 a 42.26,42.26 0 0 0 0.36,-9.34 c -0.12,-3.48 -0.24,-10.2 -0.37,-20 -0.12,-10 -0.32,-16.94 -0.57,-20.55 -0.35,-4.83 -0.89,-7.71 -1.88,-9.94 a 11.33,11.33 0 0 0 -10.35,-6.95 z m -23.92,27.84 h 4.2 a 25.5,25.5 0 0 1 3.5,0.25 15.8,15.8 0 0 1 1.9,2 31.46,31.46 0 0 1 1.91,3.9 14.27,14.27 0 0 1 1.3,4.76 14.52,14.52 0 0 1 -0.45,4.43 16.57,16.57 0 0 1 -2,4.48 12.75,12.75 0 0 1 -2.73,3.24 7.92,7.92 0 0 1 -2.66,1.37 3.37,3.37 0 0 1 -0.92,0.14 3.23,3.23 0 0 1 -0.68,-0.08 40.25,40.25 0 0 1 -5,-1.51 8.48,8.48 0 0 1 -2.33,-1.17 c -0.88,-0.7 -1.76,-1.38 -2.64,-2 -0.11,-1.35 -0.22,-3.52 -0.22,-6.93 a 22.94,22.94 0 0 1 1.17,-7.56 10.08,10.08 0 0 1 3,-4 c 1,-0.46 1.87,-0.89 2.61,-1.3 z m -6.49,20.81 z"
															id="path24"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 77.652493,46.47045 a 10.9,10.9 0 0 0 -5.47,1.53 12.56,12.56 0 0 0 -6.13,9.64 l -0.15,1.54 a 6.85,6.85 0 0 0 0,0.79 v 1.25 c 1.17,28 1.93,44.92 2.08,47.09 0.43,6.63 3.69,9.61 6.35,10.93 a 10.63,10.63 0 0 0 4.82,1.16 11,11 0 0 0 8.38,-4 c 2.42,-2.92 3.06,-6.56 2.87,-16.26 -0.12,-5.92 -0.19,-12.27 -0.19,-18.9 0,-4 0,-6.5 0,-8.18 a 9.8,9.8 0 0 1 2.09,-2.2 5.88,5.88 0 0 1 2.43,-1 11.26,11.26 0 0 1 2.13,-0.24 3.76,3.76 0 0 1 0.76,0.06 0.68,0.68 0 0 1 0.43,0.2 29.57,29.57 0 0 0 4.369997,3.4 c 0.27,0.17 0.78,0.5 1.62,1.09 a 12.91,12.91 0 0 0 7.52,2.63 11.33,11.33 0 0 0 8.86,-4.37 12,12 0 0 0 2.48,-9.25 12.37,12.37 0 0 0 -5.89,-8.72 25.58,25.58 0 0 1 -2.59,-1.95 22.39,22.39 0 0 0 -8.66,-4.52 41.12,41.12 0 0 0 -8.339997,-1.19 c -0.56,0 -1.13,0 -1.69,0 a 34.48,34.48 0 0 0 -8.41,1 22.92,22.92 0 0 0 -2.55,0.79 11.43,11.43 0 0 0 -7.09,-2.3 z"
															id="path26"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 140.42249,40.48045 a 13.67,13.67 0 0 0 -7.8,2.64 l -0.31,0.21 a 7.68,7.68 0 0 0 -2.55,2.93 l -0.16,0.34 c -4.12,8.31 -6.32,13.62 -7.13,17.21 a 88.54,88.54 0 0 0 -1.6,9.77 64.14,64.14 0 0 0 -0.42,9.47 21.89,21.89 0 0 0 3.87,11.48 26.61,26.61 0 0 0 7.33,7.49 43.7,43.7 0 0 0 6.69,3.66 22.23,22.23 0 0 0 9,2 h 6.81 a 35.22,35.22 0 0 0 8.48,-0.79 30.65,30.65 0 0 0 8.75,-4.2 22.92,22.92 0 0 0 9,-9.83 42.09,42.09 0 0 0 2.86,-8.86 53.31,53.31 0 0 0 0.93,-10.47 c 0,-4.4 -1.11,-9.64 -3.3,-15.59 -2.73,-7.4 -5.3,-12 -10.33,-13.52 a 13.18,13.18 0 0 0 -3.83,-0.58 14,14 0 0 0 -6.81,1.82 11.29,11.29 0 0 0 -4.95,5.45 12.56,12.56 0 0 0 0.47,10.3 c 0.91,2.05 2,4.41 3.29,7 a 10.46,10.46 0 0 1 0.92,4.59 31.37,31.37 0 0 1 -0.54,6.37 11.24,11.24 0 0 1 -0.79,2.65 10.24,10.24 0 0 1 -1.83,2 4.29,4.29 0 0 1 -1.84,1 14.89,14.89 0 0 1 -3.88,0.56 11.12,11.12 0 0 1 -3.22,-0.48 6.93,6.93 0 0 1 -2.3,-1.2 5.81,5.81 0 0 1 -1,-1 16.67,16.67 0 0 1 -0.49,-3.38 18.86,18.86 0 0 1 0.47,-6.13 65.62,65.62 0 0 1 2.6,-7.82 34.53,34.53 0 0 1 1.91,-4.24 15.54,15.54 0 0 0 2.93,-7 13.05,13.05 0 0 0 -1.41,-8 11,11 0 0 0 -9.82,-5.85 z"
															id="path28"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 195.92249,4.4985857e-4 a 10.71,10.71 0 0 0 -7,2.52000004143 c -2.93,2.47 -3.42,5.56 -3.73,9.0500001 -0.33,3.76 -0.52,10.69 -0.61,21.81 -0.15,18.9 -0.37,25.54 -0.53,27.77 -0.26,3.61 -0.46,10.53 -0.58,20.55 -0.12,9.76 -0.25,16.49 -0.37,20 a 43,43 0 0 0 0.36,9.35 c 1.36,6.81 6.5,9.23 10.49,9.23 a 10.85,10.85 0 0 0 8.3,-3.89 q 0.81,0.51 1.65,1 a 22.47,22.47 0 0 0 8.8,2.72 c 0.64,0 1.31,0.07 2,0.07 a 45.16,45.16 0 0 0 6.29,-0.51 c 2.75,-0.39 4.82,-0.71 6.33,-1 a 23.46,23.46 0 0 0 9.14,-4 26,26 0 0 0 7.36,-7 l 3,-4.45 a 19.71,19.71 0 0 0 3.19,-9.93 60.41,60.41 0 0 0 0,-7.37 c -0.13,-2.23 -0.32,-4.66 -0.58,-7.23 a 33.4,33.4 0 0 0 -2.09,-9 c -0.74,-1.82 -1.53,-3.84 -2.38,-6 a 19.27,19.27 0 0 0 -5.88,-8.55 25.89,25.89 0 0 0 -6,-3.45 c -1.63,-0.68 -3.6,-1.43 -5.85,-2.22 a 24.7,24.7 0 0 0 -8.21,-1.47 c -0.47,0 -0.94,0 -1.4,0 a 51.12,51.12 0 0 0 -8.84,1.55 c -0.6,0.15 -1.19,0.3 -1.75,0.46 0,-3.25 0.1,-7.3 0.19,-12.33 0.33,-19.27 0.6,-22.7 0.67,-23.29 0.59,-4.7400001 -0.89,-10.7100001 -6.81,-13.2800001 a 13.09,13.09 0 0 0 -5.16,-1.11000004143 z M 212.50249,72.35045 a 25.75,25.75 0 0 1 3.51,-0.25 h 4.19 c 0.75,0.41 1.61,0.84 2.62,1.3 a 10.18,10.18 0 0 1 3,4 23.21,23.21 0 0 1 1.2,7.6 c 0,3.4 -0.1,5.57 -0.22,6.93 -0.88,0.65 -1.76,1.32 -2.63,2 a 8.63,8.63 0 0 1 -2.31,1.17 41.15,41.15 0 0 1 -5,1.51 3.4,3.4 0 0 1 -0.69,0.08 3,3 0 0 1 -0.91,-0.14 7.66,7.66 0 0 1 -2.66,-1.37 12.75,12.75 0 0 1 -2.73,-3.24 16.32,16.32 0 0 1 -2,-4.48 14.84,14.84 0 0 1 -0.45,-4.46 14.27,14.27 0 0 1 1.29,-4.76 29.65,29.65 0 0 1 1.92,-3.94 16.6,16.6 0 0 1 1.9,-2 z"
															id="path30"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 303.64249,44.35045 a 11.28,11.28 0 0 0 -1.42,0.09 11.47,11.47 0 0 0 -8.71,5.85 c -0.75,-0.22 -1.54,-0.44 -2.37,-0.64 a 51.45,51.45 0 0 0 -8.84,-1.55 c -0.47,0 -0.94,-0.05 -1.41,-0.05 a 24.6,24.6 0 0 0 -8.19,1.48 c -2.24,0.79 -4.21,1.53 -5.85,2.22 a 25.83,25.83 0 0 0 -6,3.45 19.34,19.34 0 0 0 -5.89,8.55 c -0.85,2.19 -1.64,4.21 -2.37,6 a 33,33 0 0 0 -2.09,9 c -0.27,2.59 -0.46,5 -0.59,7.23 a 60.57,60.57 0 0 0 0,7.38 19.71,19.71 0 0 0 3.19,9.92 l 3,4.45 a 26,26 0 0 0 7.36,7 23.44,23.44 0 0 0 9.15,4 c 1.53,0.26 3.66,0.58 6.32,1 a 45.16,45.16 0 0 0 6.29,0.51 c 0.7,0 1.38,0 2,-0.07 a 22.52,22.52 0 0 0 8.8,-2.72 c 0.56,-0.3 1.11,-0.62 1.64,-1 a 10.85,10.85 0 0 0 8.3,3.89 c 4,0 9.12,-2.42 10.49,-9.23 a 43,43 0 0 0 0.36,-9.35 c -0.12,-3.5 -0.24,-10 -0.37,-20 -0.13,-10 -0.32,-16.92 -0.57,-20.55 -0.35,-4.83 -0.9,-7.71 -1.89,-9.94 a 11.28,11.28 0 0 0 -10.33,-6.95 z m -23.93,27.84 h 4.2 a 25.5,25.5 0 0 1 3.5,0.25 16.6,16.6 0 0 1 1.9,2 31.46,31.46 0 0 1 1.92,3.94 14.27,14.27 0 0 1 1.29,4.76 14.52,14.52 0 0 1 -0.45,4.43 16.39,16.39 0 0 1 -2,4.47 12.66,12.66 0 0 1 -2.73,3.25 7.74,7.74 0 0 1 -2.66,1.37 3,3 0 0 1 -0.91,0.14 3.25,3.25 0 0 1 -0.69,-0.08 40.25,40.25 0 0 1 -5,-1.51 8.48,8.48 0 0 1 -2.3,-1.17 c -0.88,-0.7 -1.76,-1.38 -2.64,-2 -0.11,-1.35 -0.22,-3.51 -0.22,-6.93 a 22.94,22.94 0 0 1 1.17,-7.56 10.08,10.08 0 0 1 3,-4 c 1,-0.46 1.87,-0.89 2.61,-1.3 z"
															id="path32"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 329.97249,91.34045 a 7.75,7.75 0 0 0 -2.72,0.5 l -2,0.73 c -6.31,2.37 -8.41,6.42 -9.07,9.4 a 17.28,17.28 0 0 0 -0.31,6.24 c 0.34,2.42 1.84,6.86 8,9.41 a 15.82,15.82 0 0 0 6.09,1.28 13.44,13.44 0 0 0 4.24,-0.68 14.63,14.63 0 0 0 6.74,-4.5 12,12 0 0 0 2.42,-10.72 13.22,13.22 0 0 0 -5.24,-7.66 18.87,18.87 0 0 0 -2.45,-1.52 7.43,7.43 0 0 0 -1.3,-1.13 7.72,7.72 0 0 0 -4.4,-1.38 z"
															id="path34"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 355.71249,18.62045 a 15,15 0 0 0 -8.1,2.32 14.09,14.09 0 0 0 -5.61,6.39 19.47,19.47 0 0 0 -1.43,5.58 37,37 0 0 0 -0.24,4.15 14.77,14.77 0 0 0 1.53,6.71 30,30 0 0 0 1.87,3.23 c 0.64,1 1.52,2.15 2.69,3.6 l 0.23,0.3 0.31,0.36 a 17,17 0 0 0 -0.33,3.42 19.82,19.82 0 0 0 0.86,5.8 c 1.93,23.34 2.93,36.27 3.06,37.75 0.51,6.13 4,9 6.09,10.18 a 11.79,11.79 0 0 0 5.91,1.63 10.93,10.93 0 0 0 5.59,-1.55 11.81,11.81 0 0 0 5.52,-9.37 c 0.13,-1.27 0.27,-2.71 -1.66,-24 -1.67,-18.31 -2.1,-22.1 -2.29,-23.35 a 14.74,14.74 0 0 0 -0.74,-2.81 20.84,20.84 0 0 0 2.11,-3.79 20.89,20.89 0 0 0 1.86,-9.89 20.42,20.42 0 0 0 -2.4,-8.38 14.92,14.92 0 0 0 -8.06,-7 19.67,19.67 0 0 0 -6.77,-1.29 z"
															id="path36"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 402.19249,6.1804499 a 12.21,12.21 0 0 0 -8.63,3.73 c -3.08,3.0800001 -3.91,7.0800001 -3.71,17.8300001 0.08,3.79 0.18,7.64 0.31,11.51 -10.77,0.94 -11.89,1.59 -13.57,2.56 a 11.43,11.43 0 0 0 -6,10 10.39,10.39 0 0 0 2.18,6.36 11.38,11.38 0 0 0 8,4.2 18.47,18.47 0 0 0 2.25,0.11 c 1.66,0 3.9,-0.13 6.95,-0.41 0.05,3.76 0.12,8.62 0.21,14.43 0.26,17.8 0.2,23.72 0.1,25.54 -0.26,4.87 0.31,8.22 1.83,10.85 a 11.29,11.29 0 0 0 9.8,6 c 2.85,0 6.93,-1.14 10.13,-6.55 1.88,-3.19 2.45,-7.57 2.1,-16.16 -0.24,-5.89 -0.3,-14.4 -0.18,-25.28 0,-4.2 0.09,-7.61 0.12,-10.28 h 0.94 c 5.26,0 9.28,-1.55 11.93,-4.6 a 10.84,10.84 0 0 0 0.47,-14.46 c -1.65,-2 -4.72,-4.33 -10,-4.33 h -0.7 c -0.75,0 -1.63,0.07 -2.64,0.13 0,-0.8 0,-1.67 -0.06,-2.65 -0.13,-7.32 -0.33,-12.24 -0.64,-15.51 a 22.58,22.58 0 0 0 -1.25,-6 10.47,10.47 0 0 0 -8.2,-6.9100001 12.19,12.19 0 0 0 -1.68,-0.12 z"
															id="path38"
															inkscape:connector-curvature="0"
															style="fill:#e75e24" />
														<path
															d="m 56.152493,112.63045 c -0.91,0 -2.2,-0.4 -3.15,-2.29 -0.37,-0.75 -0.75,-2.4 -0.86,-8.46 l -4.18,4.54 a 20.58,20.58 0 0 1 -5.39,4.18 14.81,14.81 0 0 1 -5.76,1.84 32.08,32.08 0 0 1 -6.62,-0.38 c -2.59,-0.38 -4.66,-0.69 -6.14,-0.94 a 16.55,16.55 0 0 1 -6.13,-2.81 18.79,18.79 0 0 1 -5.22,-4.85 l -2.9999998,-4.45 a 12.09,12.09 0 0 1 -1.91,-6.09 53.72,53.72 0 0 1 0,-6.47 c 0.12,-2.12 0.31,-4.45 0.56,-6.92 a 25.49,25.49 0 0 1 1.58,-6.88 c 0.7399998,-1.84 1.5399998,-3.88 2.3999998,-6.1 a 11.93,11.93 0 0 1 3.43,-5.25 18.7,18.7 0 0 1 4.22,-2.42 c 1.52,-0.63 3.35,-1.32 5.45,-2.06 a 16.18,16.18 0 0 1 6.51,-1 44.62,44.62 0 0 1 7.48,1.33 36.76,36.76 0 0 1 7.34,2.52 13.85,13.85 0 0 1 3.22,2.22 c -0.13,-1.13 -0.23,-2.15 -0.31,-3 a 9.39,9.39 0 0 1 0.45,-4.16 3.87,3.87 0 0 1 3.3,-2.62 3.53,3.53 0 0 1 3.73,2.34 c 0.57,1.29 1,3.62 1.23,7.34 0.25,3.46 0.44,10.23 0.56,20.09 0.12,9.86 0.25,16.63 0.37,20.17 a 38.84,38.84 0 0 1 -0.21,7.56 c -0.57,2.62 -2.09,3.02 -2.95,3.02 z m -39.2,-37.63 a 30.68,30.68 0 0 0 -1.59,10.09 79.75,79.75 0 0 0 0.36,8.72 4.62,4.62 0 0 0 1.61,3.43 c 1.25,0.88 2.53,1.83 3.78,2.84 a 16.3,16.3 0 0 0 4.43,2.37 50.26,50.26 0 0 0 5.93,1.8 10.82,10.82 0 0 0 5.56,-0.17 15.59,15.59 0 0 0 5.26,-2.71 20.44,20.44 0 0 0 4.49,-5.2 24,24 0 0 0 3,-6.63 22,22 0 0 0 0.64,-6.83 21.6,21.6 0 0 0 -1.92,-7.46 29.67,29.67 0 0 0 -2.79,-5.45 23.34,23.34 0 0 0 -3,-3.13 7.06,7.06 0 0 0 -3.86,-1.86 33.63,33.63 0 0 0 -4.79,-0.36 h -4.59 a 4.61,4.61 0 0 0 -2.53,0.5 24.81,24.81 0 0 1 -3.76,1.9 18.34,18.34 0 0 0 -6.23,8.15 z"
															id="path40"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														<path
															d="m 79.112493,112.62045 a 3.09,3.09 0 0 1 -1.36,-0.33 c -1.25,-0.63 -1.94,-2.11 -2.1,-4.54 -0.12,-1.85 -0.81,-16.93 -2.06,-46.89 v -0.93 l 0.16,-1.54 a 4.8,4.8 0 0 1 2.27,-3.72 3.28,3.28 0 0 1 1.63,-0.46 3.14,3.14 0 0 1 3,1.46 c 0.79,1.63 0.7,4 0.88,4.63 l 1,-1.06 a 13.19,13.19 0 0 1 6.64,-3.76 26.8,26.8 0 0 1 7.84,-0.78 32.76,32.76 0 0 1 6.759997,1 14.81,14.81 0 0 1 5.7,3 35.07,35.07 0 0 0 3.42,2.56 4.58,4.58 0 0 1 2.34,3.24 4.26,4.26 0 0 1 -0.86,3.34 3.54,3.54 0 0 1 -2.8,1.47 5.3,5.3 0 0 1 -3.06,-1.2 c -0.84,-0.59 -1.56,-1.07 -2.13,-1.42 a 23,23 0 0 1 -3.2,-2.58 8.42,8.42 0 0 0 -4.119997,-2 15.21,15.21 0 0 0 -5.92,0.18 13.39,13.39 0 0 0 -5.72,2.41 17.58,17.58 0 0 0 -3.91,4.3 c -0.78,1.22 -1.1,1.8 -1.23,2.06 0.14,1.1 0.14,3.64 0.14,10.1 0,6.69 0.06,13.1 0.18,19 0.18,8.88 -0.46,10.41 -1.07,11.15 a 3.18,3.18 0 0 1 -2.42,1.31 z"
															id="path42"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														<path
															d="m 154.19249,99.93045 h -6.77 a 14.68,14.68 0 0 1 -6,-1.32 38.08,38.08 0 0 1 -5.54,-3 19,19 0 0 1 -5.17,-5.36 14.21,14.21 0 0 1 -2.56,-7.46 57,57 0 0 1 0.37,-8.33 83.22,83.22 0 0 1 1.47,-8.91 c 0.65,-2.89 2.77,-8 6.51,-15.47 l 0.16,-0.34 0.31,-0.21 a 6.12,6.12 0 0 1 3.45,-1.32 3.24,3.24 0 0 1 3,1.79 5.23,5.23 0 0 1 0.53,3.29 7.87,7.87 0 0 1 -1.56,3.58 30.56,30.56 0 0 0 -2.79,5.85 74.79,74.79 0 0 0 -2.91,8.76 26.79,26.79 0 0 0 -0.7,8.65 c 0.29,3.73 0.88,5.5 1.32,6.33 a 11.49,11.49 0 0 0 3.11,3.54 14.43,14.43 0 0 0 4.85,2.53 20,20 0 0 0 11.34,0 12.05,12.05 0 0 0 5.09,-2.77 17.42,17.42 0 0 0 3.25,-3.79 17.19,17.19 0 0 0 1.67,-4.97 39.14,39.14 0 0 0 0.71,-8 18.1,18.1 0 0 0 -1.71,-8 c -1.23,-2.53 -2.3,-4.8 -3.17,-6.77 -1.66,-3.73 0.27,-5.29 1.18,-5.79 a 5.83,5.83 0 0 1 4.64,-0.63 c 1.23,0.38 2.72,1.7 5.34,8.81 a 39,39 0 0 1 2.81,12.94 45.19,45.19 0 0 1 -0.77,8.91 34.11,34.11 0 0 1 -2.32,7.21 15.31,15.31 0 0 1 -6.06,6.46 25,25 0 0 1 -6.49,3.24 29.16,29.16 0 0 1 -6.59,0.55 z"
															id="path44"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														<path
															d="m 193.96249,112.54045 c -0.86,0 -2.38,-0.4 -2.91,-3 a 38.84,38.84 0 0 1 -0.21,-7.56 c 0.12,-3.56 0.25,-10.34 0.37,-20.17 0.12,-9.83 0.31,-16.62 0.56,-20.09 0.25,-3.47 0.43,-12.92 0.55,-28.26 0.19,-23.8300001 0.84,-24.3700001 1.59,-25.0000001 0.75,-0.63 2,-1.12 4.1,-0.22 1.24,0.54 2.62,1.8800001 2.21,5.2200001 -0.25,1.92 -0.49,10 -0.73,24.11 -0.24,14.11 -0.31,22.46 -0.19,25.06 a 13.35,13.35 0 0 1 4,-3 36.42,36.42 0 0 1 7.33,-2.52 44.62,44.62 0 0 1 7.48,-1.34 16.3,16.3 0 0 1 6.51,1 c 2.11,0.74 3.95,1.44 5.45,2.06 a 18.27,18.27 0 0 1 4.22,2.42 11.93,11.93 0 0 1 3.43,5.25 c 0.86,2.22 1.67,4.26 2.4,6.1 a 25.4,25.4 0 0 1 1.58,6.88 c 0.25,2.47 0.44,4.8 0.56,6.92 a 53.72,53.72 0 0 1 0,6.47 12.18,12.18 0 0 1 -1.9,6.09 l -3,4.45 a 18.65,18.65 0 0 1 -5.22,4.85 16.48,16.48 0 0 1 -6.13,2.81 c -1.45,0.25 -3.46,0.55 -6.14,0.94 a 32.12,32.12 0 0 1 -6.62,0.38 14.91,14.91 0 0 1 -5.76,-1.84 20.36,20.36 0 0 1 -5.38,-4.19 l -4.19,-4.53 c -0.1,6.06 -0.49,7.71 -0.86,8.46 -0.9,1.85 -2.19,2.25 -3.1,2.25 z m 22.05,-48.18 a 33.66,33.66 0 0 0 -4.8,0.36 7.06,7.06 0 0 0 -3.86,1.86 24,24 0 0 0 -3,3.13 30.07,30.07 0 0 0 -2.79,5.45 21.6,21.6 0 0 0 -1.92,7.46 22.36,22.36 0 0 0 0.69,6.79 23.92,23.92 0 0 0 3,6.63 20.22,20.22 0 0 0 4.48,5.2 15.59,15.59 0 0 0 5.26,2.71 10.72,10.72 0 0 0 5.56,0.17 51,51 0 0 0 5.94,-1.8 16.38,16.38 0 0 0 4.42,-2.37 c 1.25,-1 2.53,-2 3.78,-2.84 a 4.61,4.61 0 0 0 1.65,-3.42 80.47,80.47 0 0 0 0.36,-8.73 30.94,30.94 0 0 0 -1.58,-10.09 18.37,18.37 0 0 0 -6.24,-8.11 24.81,24.81 0 0 1 -3.76,-1.9 4.58,4.58 0 0 0 -2.53,-0.5 z"
															id="path46"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														<path
															d="m 305.95249,112.63045 c -0.91,0 -2.2,-0.4 -3.15,-2.29 -0.37,-0.75 -0.75,-2.39 -0.86,-8.46 l -4.18,4.54 a 20.58,20.58 0 0 1 -5.34,4.18 14.81,14.81 0 0 1 -5.76,1.84 31.42,31.42 0 0 1 -6.62,-0.38 c -2.6,-0.38 -4.67,-0.69 -6.14,-0.94 a 16.55,16.55 0 0 1 -6.13,-2.81 18.79,18.79 0 0 1 -5.22,-4.85 l -3,-4.45 a 12.09,12.09 0 0 1 -1.91,-6.09 53.72,53.72 0 0 1 0,-6.47 c 0.12,-2.1 0.31,-4.42 0.56,-6.92 a 25.49,25.49 0 0 1 1.58,-6.88 c 0.74,-1.84 1.54,-3.88 2.4,-6.1 a 11.93,11.93 0 0 1 3.43,-5.25 18.7,18.7 0 0 1 4.22,-2.42 c 1.52,-0.63 3.35,-1.32 5.45,-2.06 a 16.33,16.33 0 0 1 6.51,-1 44.62,44.62 0 0 1 7.48,1.34 36.76,36.76 0 0 1 7.34,2.52 13.85,13.85 0 0 1 3.22,2.22 c -0.13,-1.13 -0.23,-2.14 -0.31,-3 a 9.39,9.39 0 0 1 0.45,-4.16 3.87,3.87 0 0 1 3.22,-2.6 3.52,3.52 0 0 1 3.73,2.34 c 0.57,1.29 1,3.62 1.23,7.34 0.25,3.49 0.44,10.25 0.56,20.09 0.13,10 0.25,16.61 0.37,20.17 a 38.84,38.84 0 0 1 -0.21,7.56 c -0.54,2.59 -2.06,2.99 -2.92,2.99 z m -39.2,-37.63 a 30.68,30.68 0 0 0 -1.59,10.09 80.09,80.09 0 0 0 0.36,8.73 4.61,4.61 0 0 0 1.61,3.42 c 1.25,0.88 2.52,1.83 3.78,2.84 a 16.3,16.3 0 0 0 4.43,2.37 50.26,50.26 0 0 0 5.93,1.8 10.82,10.82 0 0 0 5.56,-0.17 15.59,15.59 0 0 0 5.26,-2.71 20.44,20.44 0 0 0 4.49,-5.2 24.17,24.17 0 0 0 3,-6.63 22,22 0 0 0 0.69,-6.79 21.6,21.6 0 0 0 -1.92,-7.46 29.67,29.67 0 0 0 -2.79,-5.45 23.34,23.34 0 0 0 -3,-3.13 7,7 0 0 0 -3.86,-1.86 33.53,33.53 0 0 0 -4.79,-0.36 h -4.64 a 4.61,4.61 0 0 0 -2.53,0.5 24.81,24.81 0 0 1 -3.76,1.9 18.34,18.34 0 0 0 -6.23,8.11 z"
															id="path48"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														<path
															d="m 329.97249,111.17045 a 8.14,8.14 0 0 1 -3.12,-0.69 c -2,-0.83 -3.09,-2 -3.29,-3.36 a 9.87,9.87 0 0 1 0.21,-3.49 c 0.36,-1.63 1.75,-2.88 4.24,-3.82 l 2,-0.73 v 1 a 7.28,7.28 0 0 1 1.12,0.19 7.82,7.82 0 0 1 2.53,1.34 5.6,5.6 0 0 1 2.24,3.23 4.28,4.28 0 0 1 -0.85,3.88 7,7 0 0 1 -3.25,2.11 5.6,5.6 0 0 1 -1.83,0.34 z"
															id="path50"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														<path
															d="m 362.55249,102.31045 a 4.25,4.25 0 0 1 -2.09,-0.62 4.83,4.83 0 0 1 -2.2,-4.1 q -0.19,-2.22 -3.13,-38.71 a 11.74,11.74 0 0 1 -0.77,-4.22 6.05,6.05 0 0 1 1.06,-3.87 4.1,4.1 0 0 1 3.36,-1.47 c 1,0 2.79,0.48 3.28,3.64 0.26,1.65 1,9.14 2.24,22.88 1.67,18.4 1.75,21.66 1.66,22.51 a 4.33,4.33 0 0 1 -1.8,3.51 3.1,3.1 0 0 1 -1.61,0.45 z m -5.63,-55.31 a 10.57,10.57 0 0 1 -3.87,-0.85 l -0.36,-0.14 -0.23,-0.3 c -1,-1.26 -1.78,-2.29 -2.3,-3.06 v 0 a 24.45,24.45 0 0 1 -1.39,-2.38 7.26,7.26 0 0 1 -0.71,-3.25 29.63,29.63 0 0 1 0.2,-3.31 11.49,11.49 0 0 1 0.85,-3.37 6.32,6.32 0 0 1 2.6,-2.88 c 2.34,-1.47 5,-1.47 8.12,-0.32 a 7.16,7.16 0 0 1 3.92,3.44 12.77,12.77 0 0 1 1.48,5.23 13.42,13.42 0 0 1 -1.23,6.24 c -1,2.37 -2.22,3.78 -3.6,4.3 a 9.92,9.92 0 0 1 -3.48,0.65 z m -0.76,-7.16 a 1.86,1.86 0 0 0 1.66,0 v 0 a 3.76,3.76 0 0 0 0.75,-1.22 4.27,4.27 0 0 0 0.44,-2.27 6.17,6.17 0 0 0 -0.59,-2 1.65,1.65 0 0 0 -0.84,-0.81 2.14,2.14 0 0 0 -2.15,0 1.22,1.22 0 0 0 -0.5,0.55 3.52,3.52 0 0 0 -0.22,1.11 c 0,0.56 0,1.1 0,1.63 a 3.48,3.48 0 0 0 0.12,1 3.75,3.75 0 0 0 0.4,0.87 9.65,9.65 0 0 0 0.93,1.18 z"
															id="path52"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														<path
															d="m 401.91249,111.14045 c -0.85,0 -2.07,-0.37 -3.11,-2.15 -0.72,-1.24 -1,-3.32 -0.79,-6.55 0.15,-2.84 0.12,-11.61 -0.1,-26.08 -0.18,-12.21 -0.29,-20 -0.32,-22.46 a 27.22,27.22 0 0 0 -6,0.22 60.67,60.67 0 0 1 -9.95,0.55 c -3,-0.34 -3.32,-2.13 -3.32,-2.88 a 3.74,3.74 0 0 1 2.16,-3.29 c 0.58,-0.34 1.66,-1 17.69,-2.13 -0.27,-6.3 -0.47,-12.61 -0.58,-18.78 v 0 c -0.19,-9.75 0.65,-11.42 1.44,-12.21 a 4.24,4.24 0 0 1 3.69,-1.38 c 2.1,0.31 2.64,3.2 2.9,6 0.29,3 0.48,7.92 0.61,14.93 0.13,7.01 0.3,9.57 0.41,10.43 a 14.54,14.54 0 0 0 3.42,0.05 c 2.93,-0.18 5.25,-0.31 6.89,-0.37 2.09,-0.08 3.59,0.44 4.51,1.54 0.51,0.62 1.52,2.29 -0.35,4.43 -1.13,1.3 -3.12,1.93 -6.09,1.93 -2.44,0 -4.73,0.08 -6.8,0.23 a 7.61,7.61 0 0 0 -1.81,0.3 c 0,1.58 -0.06,7.07 -0.18,17.4 -0.12,11 -0.06,19.67 0.18,25.68 0.35,8.43 -0.37,10.79 -1,11.91 -0.63,1.12 -1.85,2.68 -3.5,2.68 z"
															id="path54"
															inkscape:connector-curvature="0"
															style="fill:#ffffff" />
														</svg>
													</div>
												</div>
											</div>
										</div>
									</div>
								</xsl:variable>

								<div class="containers">
									<table class="report-container" style="{$Page_Break}">
										<tfoot class="report-footer-space">
											<tr>
												<td class="no-padding">
													<div class="report-footer in-table">
														<xsl:copy-of select="$PAGE_FOOTER"/>
													</div>
												</td>

											</tr>
										</tfoot>
										<tbody class="report-content">
											<tr>
												<td class="no-padding">
													<div class="main">

														<div class="header-fattura">
															<xsl:if test="$TOTALBODY>1">
																<div class="numeroDocumento">
																	Numero documento nel lotto:
																	<xsl:value-of select="position()" /> di <xsl:value-of select="$TOTALBODY" />
																</div>

															</xsl:if>

															<div class="flex-row">
																<div class="flex-cell"></div>
																<div class="flex-cell blocco-fattura">
																	<div class="flex-container">
																		<div class="titolo">
																			<xsl:variable name="TDOC">
																				<xsl:if test="DatiGenerali/DatiGeneraliDocumento/TipoDocumento">
																					<xsl:value-of select="DatiGenerali/DatiGeneraliDocumento/TipoDocumento" />
																				</xsl:if>
																			</xsl:variable>
																			<xsl:choose>
																				<xsl:when test="$TDOC='TD01' or $TDOC='TD24' or $TDOC='TD25'">Fattura</xsl:when>
																				<xsl:when test="$TDOC='TD02'">Acconto/anticipo su fattura</xsl:when>
																				<xsl:when test="$TDOC='TD03'">Acconto/anticipo su parcella</xsl:when>
																				<xsl:when test="$TDOC='TD04'">Nota di credito</xsl:when>
																				<xsl:when test="$TDOC='TD05'">Nota di debito</xsl:when>
																				<xsl:when test="$TDOC='TD06'">Parcella</xsl:when>
																				<xsl:when test="$TDOC='TD16' or $TDOC='TD17' or $TDOC='TD18' or $TDOC='TD19' or $TDOC='TD20' or $TDOC='TD21' or $TDOC='TD22' or $TDOC='TD23' or $TDOC='TD26' or $TDOC='TD27'">Autofattura</xsl:when>
																				<xsl:otherwise>
																					<span>(!!! codice non previsto !!!)</span>
																				</xsl:otherwise>
																			</xsl:choose>
																		</div>
																		<xsl:if test="DatiGenerali">
																			<xsl:if test="DatiGenerali/DatiGeneraliDocumento/Numero">
																				<div class="dati-generali">
																					nr.&#160;<span><xsl:value-of select="DatiGenerali/DatiGeneraliDocumento/Numero" /></span>
																					<xsl:if test="DatiGenerali/DatiGeneraliDocumento/Data">
																						&#160;del&#160;<span><xsl:call-template name="FormatDateSmart"><xsl:with-param name="DateTime" select="DatiGenerali/DatiGeneraliDocumento/Data" /></xsl:call-template>
																						</span>
																					</xsl:if>
																				</div>
																			</xsl:if>

																		</xsl:if>

																		<xsl:if test="$soggettoEmittente = 1">
																			<div class="dati">
																				<xsl:copy-of select="$DATI_SOGGETTO_EMITTENTE" />
																				<xsl:copy-of select="$DATI_TERZO_INTERMEDIARIO_O_SOGGETTO_EMITTENTE" />
																			</div>
																		</xsl:if>
																	</div>
																</div>
															</div>

															<div class="flex-row">
																<div class="flex-cell blocco-fornitore">
																	<div class="flex-container">
																		<div class="titolo">Fornitore</div>

																		<xsl:copy-of select="$DATI_CEDENTE_PRESTATORE" />
																	</div>
																</div>
																<div class="flex-cell blocco-cliente">
																	<div class="flex-container">
																		<div class="titolo">Cliente</div>

																		<xsl:copy-of select="$DATI_CESSIONARIO_COMMITTENTE" />
																	</div>
																</div>
															</div>

															<div class="hline"></div>
														</div>

														<xsl:variable name="NUMERO_LINEE" select="count(DatiBeniServizi/DettaglioLinee)" />
														<!--INIZIO DATI BENI E SERVIZI-->
														<xsl:if test="DatiBeniServizi and DatiBeniServizi/DettaglioLinee">
															<div class="sezione">

																<xsl:if test="DatiBeniServizi/DettaglioLinee">

																	<xsl:variable name="maxDecimaliQuantita">
																		<xsl:call-template name="ComputeNumeriDecimaliMax">
																			<xsl:with-param name="nodeList" select="DatiBeniServizi/DettaglioLinee" />
																			<xsl:with-param name="nomeCampo" select="'Quantita'"/>
																			<xsl:with-param name="totalSoFar" select="0" />
																		</xsl:call-template>
																	</xsl:variable>
																	<xsl:variable name="formatDecimaliQuantita">
																		<xsl:call-template name="ComputeFormatDecimalString">
																			<xsl:with-param name="num" select="$maxDecimaliQuantita" />
																			<xsl:with-param name="stringSoFar"/>
																		</xsl:call-template>
																	</xsl:variable>

																	<xsl:variable name="maxDecimaliPrezzoUnitario">
																		<xsl:call-template name="ComputeNumeriDecimaliMax">
																			<xsl:with-param name="nodeList" select="DatiBeniServizi/DettaglioLinee" />
																			<xsl:with-param name="nomeCampo" select="'PrezzoUnitario'"/>
																			<xsl:with-param name="totalSoFar" select="0" />
																		</xsl:call-template>
																	</xsl:variable>
																	<xsl:variable name="formatDecimaliPrezzoUnitario">
																		<xsl:call-template name="ComputeFormatDecimalString">
																			<xsl:with-param name="num" select="$maxDecimaliPrezzoUnitario" />
																			<xsl:with-param name="stringSoFar"/>
																		</xsl:call-template>
																	</xsl:variable>

																	<xsl:variable name="maxDecimaliPrezzoTotale">
																		<xsl:call-template name="ComputeNumeriDecimaliMax">
																			<xsl:with-param name="nodeList" select="DatiBeniServizi/DettaglioLinee" />
																			<xsl:with-param name="nomeCampo" select="'PrezzoTotale'"/>
																			<xsl:with-param name="totalSoFar" select="0" />
																		</xsl:call-template>
																	</xsl:variable>
																	<xsl:variable name="formatDecimaliPrezzoTotale">
																		<xsl:call-template name="ComputeFormatDecimalString">
																			<xsl:with-param name="num" select="$maxDecimaliPrezzoTotale" />
																			<xsl:with-param name="stringSoFar"/>
																		</xsl:call-template>
																	</xsl:variable>

																	<div class="only-mobile sectionHeader">
																		PRODOTTI E SERVIZI
																	</div>
																	<table class="tableDesktop eTable">
																		<thead class="eTableHeadGrey">
																			<tr>
																				<th colspan="9" class="sectionHeader">
																					PRODOTTI E SERVIZI
																				</th>
																			</tr>
																			<tr class="no-mobile">
																				<th style="width: 4.5%">Nr</th>
																				<th>Descrizione</th>
																				<th colspan="2" class="" style="width: 10.5%;text-align: right;">Quantit&#224;</th>
																				<th class="importo" style="width: 16%;">Prezzo</th>
																				<th class="importo" style="width: 8%;">Sc/Mg</th>
																				<th class="importo" style="width: 16%;">Importo</th>
																				<th class="importo" style="width: 6.5%;">IVA</th>
																				<th class="center" style="width: 8%;">Natura IVA</th>
																			</tr>
																		</thead>
																		<tbody>

																			<xsl:variable name="formatNumDec">0,00######</xsl:variable>

																			<xsl:for-each select="DatiBeniServizi/DettaglioLinee">
																				<tr class="eTableRow">
																					<td>
																						<span class="chiave">Nr</span>
																						<span class="valore">
																							<xsl:value-of select="NumeroLinea" />
																						</span>
																					</td>
																					<td>
																						<span class="chiave">Descrizione</span>
																						<xsl:if test="Descrizione">
																							<span class="valore">
																								<xsl:value-of select="Descrizione" />
																							</span>
																						</xsl:if>
																					</td>
																					<td class="importo">
																						<span class="chiave">Quantit&#224;</span>
																						<xsl:if test="Quantita">
																							<span class="valore">
																								<span style="display: inline-block;text-align: right; ">
																									<xsl:value-of select="format-number(Quantita, $formatDecimaliQuantita, 'euroFormat')" />
																								</span>
																								<span class="quantita only-mobile-inline" style="padding-left: 3px; text-align: left;">
																									<xsl:if test="UnitaMisura">
																										<xsl:value-of select="UnitaMisura" />
																									</xsl:if>
																								</span>
																							</span>
																						</xsl:if>
																					</td>
																					<td class="importo only-desktop" style="width:2.2%">
																						<xsl:if test="Quantita">
																							<span class="valore">
																								<xsl:if test="UnitaMisura">
																									<xsl:value-of select="UnitaMisura" />
																								</xsl:if>
																							</span>
																						</xsl:if>
																					</td>
																					<td class="importo">
																						<span class="chiave">Prezzo</span>
																						<xsl:if test="PrezzoUnitario">
																							<span class="valore">
																								<xsl:value-of select="format-number(PrezzoUnitario, $formatDecimaliPrezzoUnitario, 'euroFormat')" />&#160;&#8364;
																							</span>
																						</xsl:if>
																					</td>
																					<xsl:variable name="prezzo_totale">
																						<xsl:value-of select="PrezzoTotale" />
																					</xsl:variable>
																					<xsl:variable name="prezzo_unitario">
																						<xsl:value-of select="PrezzoUnitario" />
																					</xsl:variable>

																					<td class="importo">
																						<span class="chiave">Sc/Mg</span>
																						<xsl:if test="ScontoMaggiorazione">
																							<span class="valore">
																								<xsl:for-each select="ScontoMaggiorazione">
																									<xsl:variable name="sctMagCount" select="position()"/>
																									<xsl:if test="$sctMagCount>1">
																										<br/>
																									</xsl:if>

																										<xsl:variable name="TSCM">
																											<xsl:if test="Tipo">
																												<xsl:value-of select="Tipo" />
																											</xsl:if>
																										</xsl:variable>
																										<xsl:choose>
																											<xsl:when test="$TSCM='SC'">
																												-</xsl:when>
																											<xsl:when test="$TSCM='MG'">
																												+</xsl:when>
																											<xsl:otherwise>
																												<span>(!!! codice non previsto !!!)</span>
																											</xsl:otherwise>
																										</xsl:choose>
																									<span>
																										<xsl:choose>
																											<xsl:when test="Percentuale">
																												<xsl:value-of select="format-number(Percentuale, '0,00', 'euroFormat')"/>%
																											</xsl:when>
																											<xsl:otherwise>
																												<xsl:choose>
																													<xsl:when test="$TSCM='SC'">
																														<xsl:call-template name="ComputeScontoUnitario">
																															<xsl:with-param name="importoUnitario" select="$prezzo_unitario"/>
																															<xsl:with-param name="importoScMg" select="Importo"/>
																														</xsl:call-template>
																													</xsl:when>
																													<xsl:when test="$TSCM='MG'">
																														<xsl:call-template name="ComputeMaggiorazioneUnitario">
																															<xsl:with-param name="importoUnitario" select="$prezzo_unitario"/>
																															<xsl:with-param name="importoScMg" select="Importo"/>
																														</xsl:call-template>
																													</xsl:when>
																												</xsl:choose>
																											</xsl:otherwise>
																										</xsl:choose>
																									</span>
																								</xsl:for-each>
																							</span>
																						</xsl:if>
																					</td>
																					<td class="importo">
																						<span class="chiave">Importo</span>
																						<xsl:if test="PrezzoTotale">
																							<span class="valore">
																								<xsl:value-of select="format-number(PrezzoTotale, $formatDecimaliPrezzoTotale, 'euroFormat')" />&#160;&#8364;
																							</span>
																						</xsl:if>
																					</td>
																					<td class="importo">
																						<span class="chiave">IVA</span>
																						<xsl:if test="AliquotaIVA">
																							<span class="valore">
																								<xsl:value-of select="format-number(AliquotaIVA, '0,00', 'euroFormat')"/>%
																							</span>

																						</xsl:if>
																					</td>
																					<td class="center">
																						<span class="chiave">Natura IVA</span>
																						<xsl:if test="Natura">
																							<span class="valore">
																								<xsl:value-of select="Natura" />
																							</span>

																						</xsl:if>
																					</td>
																				</tr>
																				<tr class="eTableSubRow">
																					<td></td>
																					<td colspan="8">
																						<div class="list-container">
																							<xsl:if test="CodiceArticolo/CodiceTipo">
																								<span class="list">
																									Cod. Tipo: <xsl:value-of select="CodiceArticolo/CodiceTipo" />
																								</span>
																							</xsl:if>
																							<xsl:if test="CodiceArticolo/CodiceValore">
																								<span class="list">
																									Cod. Valore: <xsl:value-of select="CodiceArticolo/CodiceValore" />
																								</span>
																							</xsl:if>
																							<xsl:if test="TipoCessionePrestazione">
																								<span class="list">
																									Tipo cess. prestazione:
																									<xsl:variable name="TCP">
																										<xsl:value-of select="TipoCessionePrestazione" />
																									</xsl:variable>
																									<xsl:choose>
																										<xsl:when test="$TCP='SC'">
																											Sconto
																										</xsl:when>
																										<xsl:when test="$TCP='PR'">
																											Premio
																										</xsl:when>
																										<xsl:when test="$TCP='AB'">
																											Abbuono
																										</xsl:when>
																										<xsl:when test="$TCP='AC'">
																											Spesa accessoria
																										</xsl:when>
																										<xsl:when test="$TCP=''">
																										</xsl:when>
																										<xsl:otherwise>
																											<span>(!!! codice non previsto !!!)</span>
																										</xsl:otherwise>
																									</xsl:choose>
																								</span>
																							</xsl:if>
																							<xsl:if test="DataInizioPeriodo">
																								<span class="list">
																									Data inizio:
																									<xsl:call-template name="FormatDateSmart">
																										<xsl:with-param name="DateTime" select="DataInizioPeriodo" />
																									</xsl:call-template>
																								</span>
																							</xsl:if>
																							<xsl:if test="DataFinePeriodo">
																								<span class="list">
																									Data fine:
																									<xsl:call-template name="FormatDateSmart">
																										<xsl:with-param name="DateTime" select="DataFinePeriodo" />
																									</xsl:call-template>
																								</span>
																							</xsl:if>
																							<xsl:if test="RiferimentoAmministrazione">
																								<span class="list">
																									Rif. Amministrazione: <xsl:value-of select="RiferimentoAmministrazione" />
																								</span>
																							</xsl:if>
																							<xsl:if test="AltriDatiGestionali">
																								<xsl:for-each select="AltriDatiGestionali">
																									<xsl:if test="TipoDato">
																										<span class="list">
																											Tipo Dato: <xsl:value-of select="TipoDato" />
																										</span>
																									</xsl:if>
																									<xsl:if test="RiferimentoTesto">
																										<span class="list">
																											Riferimento testo: <xsl:value-of select="RiferimentoTesto" />
																										</span>
																									</xsl:if>
																									<xsl:if test="RiferimentoNumero">
																										<span class="list">
																											Riferimento numero: <xsl:value-of select="RiferimentoNumero" />
																										</span>
																									</xsl:if>
																									<xsl:if test="RiferimentoData">
																										<span class="list">
																											Riferimento data:
																											<xsl:call-template name="FormatDateSmart">
																												<xsl:with-param name="DateTime" select="RiferimentoData" />
																											</xsl:call-template>
																										</span>
																									</xsl:if>
																								</xsl:for-each>
																							</xsl:if>
																						</div>
																					</td>
																				</tr>
																			</xsl:for-each>
																		</tbody>
																	</table>

																</xsl:if>
															</div>
														</xsl:if>

														<!-- METODO DI PAGAMENTO -->
														<xsl:if test="DatiPagamento">
															<div class="only-mobile sectionHeader">
																METODO DI PAGAMENTO
															</div>

															<table class="tableDesktop eTable normal">
																<thead class="eTableHeadGrey">
																	<tr>
																		<th colspan="8" class="sectionHeader">
																			METODO DI PAGAMENTO
																		</th>
																	</tr>
																	<tr>
																		<th style="width: 7%;">Nr Rata</th>
																		<th style="width: 12%;">Metodo</th>
																		<th style="width: 14%;">Pagamento</th>
																		<th>Banca</th>
																		<th style="width: 22.5%;">IBAN</th>
																		<th style="width: 9.5%;">BIC/SWIFT</th>
																		<th style="width: 12%;">Data scadenza</th>
																		<th class="importo" style="width: 11%;">Importo</th>
																	</tr>
																</thead>
																<tbody>
																	<xsl:for-each select="DatiPagamento">

																		<xsl:variable name="CONDIZIONIPAGAMENTO">
																			<xsl:if test="CondizioniPagamento">
																				<!--
																				<span>
																					<xsl:value-of select="CondizioniPagamento" />
																				</span>
																				-->
																				<xsl:variable name="CP">
																					<xsl:value-of select="CondizioniPagamento" />
																				</xsl:variable>
																				<xsl:choose>
																					<xsl:when test="$CP='TP01'">
																						Pagamento a rate
																					</xsl:when>
																					<xsl:when test="$CP='TP02'">
																						Pagamento completo
																					</xsl:when>
																					<xsl:when test="$CP='TP03'">
																						Anticipo
																					</xsl:when>
																					<xsl:when test="$CP=''">
																					</xsl:when>
																					<xsl:otherwise>
																						<span>(!!! codice non previsto !!!)</span>
																					</xsl:otherwise>
																				</xsl:choose>
																			</xsl:if>
																		</xsl:variable>

																		<xsl:for-each select="DettaglioPagamento">
																			<tr class="eTableRow">
																				<td>
																					<span class="chiave">Nr Rata</span>
																					<span class="valore">
																						<xsl:value-of select="position()" />
																					</span>
																				</td>
																				<td>
																					<span class="chiave">Metodo</span>
																					<xsl:if test="ModalitaPagamento">
																						<span class="valore">
																							<xsl:value-of select="ModalitaPagamento" />
																							-
																							<xsl:variable name="MP">
																								<xsl:value-of select="ModalitaPagamento" />
																							</xsl:variable>
																							<xsl:choose>
																								<xsl:when test="$MP='MP01'">
																									Contanti
																								</xsl:when>
																								<xsl:when test="$MP='MP02'">
																									Assegno
																								</xsl:when>
																								<xsl:when test="$MP='MP03'">
																									Assegno circolare
																								</xsl:when>
																								<xsl:when test="$MP='MP04'">
																									Contanti presso Tesoreria
																								</xsl:when>
																								<xsl:when test="$MP='MP05'">
																									Bonifico
																								</xsl:when>
																								<xsl:when test="$MP='MP06'">
																									Vaglia cambiario
																								</xsl:when>
																								<xsl:when test="$MP='MP07'">
																									Bollettino bancario
																								</xsl:when>
																								<xsl:when test="$MP='MP08'">
																									Carta di pagamento
																								</xsl:when>
																								<xsl:when test="$MP='MP09'">
																									RID
																								</xsl:when>
																								<xsl:when test="$MP='MP10'">
																									RID utenze
																								</xsl:when>
																								<xsl:when test="$MP='MP11'">
																									RID veloce
																								</xsl:when>
																								<xsl:when test="$MP='MP12'">
																									RIBA
																								</xsl:when>
																								<xsl:when test="$MP='MP13'">
																									MAV
																								</xsl:when>
																								<xsl:when test="$MP='MP14'">
																									Quietanza erario
																								</xsl:when>
																								<xsl:when test="$MP='MP15'">
																									Giroconto su conti di contabilit&#224; speciale
																								</xsl:when>
																								<xsl:when test="$MP='MP16'">
																									Domiciliazione bancaria
																								</xsl:when>
																								<xsl:when test="$MP='MP17'">
																									Domiciliazione postale
																								</xsl:when>
																								<xsl:when test="$MP='MP18'">
																									Bollettino di c/c postale
																								</xsl:when>
																								<xsl:when test="$MP='MP19'">
																									SEPA Direct Debit
																								</xsl:when>
																								<xsl:when test="$MP='MP20'">
																									SEPA Direct Debit CORE
																								</xsl:when>
																								<xsl:when test="$MP='MP21'">
																									SEPA Direct Debit B2B
																								</xsl:when>
																								<xsl:when test="$MP='MP22'">
																									Trattenuta su somme gi&#224; riscosse
																								</xsl:when>
																								<xsl:when test="$MP='MP23'">
																									Pago PA
																								</xsl:when>
																								<xsl:when test="$MP=''">
																								</xsl:when>
																								<xsl:otherwise>
																									<span>(!!! codice non previsto !!!)</span>
																								</xsl:otherwise>
																							</xsl:choose>
																						</span>
																					</xsl:if>

																				</td>
																				<td>
																					<span class="chiave">Pagamento</span>
																					<span class="valore">
																						<xsl:copy-of select="$CONDIZIONIPAGAMENTO" />
																					</span>
																				</td>
																				<td>
																					<span class="chiave">Banca</span>
																					<xsl:if test="IstitutoFinanziario">
																						<span class="valore">
																							<xsl:value-of select="IstitutoFinanziario" />
																						</span>
																					</xsl:if>
																				</td>
																				<td>
																					<span class="chiave">IBAN</span>
																					<xsl:if test="IBAN">
																						<span class="valore">
																							<xsl:value-of select="IBAN" />
																						</span>
																					</xsl:if>
																				</td>
																				<td>
																					<span class="chiave">BIC/SWIFT</span>
																					<xsl:if test="BIC">
																						<span class="valore">
																							<xsl:value-of select="BIC" />
																						</span>
																					</xsl:if>
																				</td>
																				<td>
																					<span class="chiave">Data scadenza</span>
																					<xsl:if test="DataScadenzaPagamento">
																						<span class="valore">
																							<xsl:call-template name="FormatDateSmart">
																								<xsl:with-param name="DateTime" select="DataScadenzaPagamento" />
																							</xsl:call-template>
																						</span>
																					</xsl:if>
																				</td>
																				<td class="importo">
																					<span class="chiave">Importo</span>
																					<xsl:if test="ImportoPagamento">
																						<span class="valore">
																							<xsl:value-of select="format-number(ImportoPagamento, '0,00#####', 'euroFormat')"/>&#160;&#8364;
																						</span>
																					</xsl:if>
																				</td>
																			</tr>
																			<tr class="eTableSubRow">
																				<td colspan="8">
																					<div class="list-container">
																						<xsl:if test="Beneficiario">
																							<span class="list">
																								Beneficiario: <xsl:value-of select="Beneficiario" />
																							</span>
																						</xsl:if>
																						<xsl:if test="CodUfficioPostale">
																							<span class="list">
																								Cod. Ufficio Post.: <xsl:value-of select="CodUfficioPostale" />
																							</span>
																						</xsl:if>
																						<xsl:if test="NomeQuietanzante">
																							<span class="list">
																								Nome quietanzante: <xsl:value-of select="NomeQuietanzante" />
																							</span>
																						</xsl:if>
																						<xsl:if test="CognomeQuietanzante">
																							<span class="list">
																								Nome quietanzante: <xsl:value-of select="CognomeQuietanzante" />
																							</span>
																						</xsl:if>
																						<xsl:if test="CFQuietanzante">
																							<span class="list">
																								C.F. quietanzante: <xsl:value-of select="CFQuietanzante" />
																							</span>
																						</xsl:if>
																						<xsl:if test="TitoloQuietanzante">
																							<span class="list">
																								Titolo quietanzante: <xsl:value-of select="TitoloQuietanzante" />
																							</span>
																						</xsl:if>
																						<xsl:if test="ScontoPagamentoAnticipato">
																							<span class="list">
																								Sconto pag. anticipato: <xsl:value-of select="ScontoPagamentoAnticipato" />
																							</span>
																						</xsl:if>
																						<xsl:if test="DataLimitePagamentoAnticipato">
																							<span class="list">
																								Data limite pag. anticipato:
																								<xsl:call-template name="FormatDateSmart">
																									<xsl:with-param name="DateTime" select="DataLimitePagamentoAnticipato" />
																								</xsl:call-template>
																							</span>
																						</xsl:if>
																						<xsl:if test="PenalitaPagamentiRitardati">
																							<span class="list">
																								Penalit&#224; pag. ritardati: <xsl:value-of select="PenalitaPagamentiRitardati" />
																							</span>
																						</xsl:if>
																						<xsl:if test="DataDecorrenzaPenale">
																							<span class="list">
																								Data decorrenza penale:
																								<xsl:call-template name="FormatDateSmart">
																									<xsl:with-param name="DateTime" select="DataDecorrenzaPenale" />
																								</xsl:call-template>
																							</span>
																						</xsl:if>
																						<xsl:if test="CodicePagamento">
																							<span class="list">
																								Codice pag.: <xsl:value-of select="CodicePagamento" />
																							</span>
																						</xsl:if>
																					</div>
																				</td>
																			</tr>
																		</xsl:for-each>
																	</xsl:for-each>
																</tbody>
															</table>
														</xsl:if>

														<!--REGIME FISCALE -->
														<xsl:if test="$RegimeFiscale != '' or DatiGenerali/DatiGeneraliDocumento/DatiRitenuta or DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale">
															<table>
																<thead>
																	<tr>
																		<th class="sectionHeader">
																			REGIME FISCALE
																		</th>
																	</tr>
																</thead>
																<tbody>
																	<xsl:call-template name="PrintSezioneRegimeFiscale">
																		<xsl:with-param name="regime" select="$RegimeFiscale"/>
																		<xsl:with-param name="nodeList" select="DatiGenerali/DatiGeneraliDocumento"/>
																	</xsl:call-template>
																</tbody>
															</table>

															<div class="hline"></div>
														</xsl:if>

														<xsl:if test="DatiGenerali/DatiOrdineAcquisto or DatiGenerali/DatiContratto or DatiGenerali/DatiConvenzione or DatiGenerali/DatiRicezione or DatiGenerali/DatiFattureCollegate or DatiGenerali/DatiDDT or Allegati or DatiGenerali/DatiGeneraliDocumento/Causale or DatiGenerali/DatiGeneraliDocumento/DatiBollo or DatiGenerali/FatturaPrincipale or (DatiGenerali/DatiGeneraliDocumento/Art73 and DatiGenerali/DatiGeneraliDocumento/Art73 = 'SI') or DatiVeicoli or DatiGenerali/DatiTrasporto">
															<table>
																<thead>
																	<tr>
																		<th class="sectionHeader">
																			DATI AGGIUNTIVI
																		</th>
																	</tr>
																</thead>
																<tbody>

																	<xsl:if test="DatiGenerali/DatiOrdineAcquisto or DatiGenerali/DatiContratto or DatiGenerali/DatiConvenzione or DatiGenerali/DatiRicezione or DatiGenerali/DatiFattureCollegate or DatiGenerali/DatiDDT">
																		<tr>
																			<td class="no-padding">
																				<div class="block block-100">
																					<div class="block-title">
																						<svg height="14" width="14">
																							<circle cx="8" cy="7" r="6" stroke-width="0" fill="#888" />
																						</svg>
																						<span>Documenti correlati</span>
																					</div>
																					<div class="block-body">
																						<table class="tableDesktop eTable noUpperCase small normal">
																							<thead class="eTableHeadGrey">
																								<tr>
																									<th style="width: 13%;">Tipo doc.</th>
																									<th style="width: 13%;">Numero doc.</th>
																									<th style="width: 10%;">Data doc.</th>
																									<th style="width: 12%;">ID voce doc.</th>
																									<th>Cod. comm./conv.</th>
																									<th style="width: 9%;">CIG</th>
																									<th style="width: 9%;">CUP</th>
																									<th style="width: 15%;">Rif. righe fatt.</th>
																								</tr>
																							</thead>
																							<tbody>
																								<xsl:for-each select="DatiGenerali/DatiOrdineAcquisto">
																									<tr class="eTableRow">
																										<td>
																											<span class="chiave">Tipo doc.</span>
																											<span class="valore">Dati ordine acquisto</span>
																										</td>
																										<td>
																											<span class="chiave">Numero doc.</span>
																											<xsl:if test="IdDocumento">
																												<span class="valore"><xsl:value-of select="IdDocumento"/></span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Data doc.</span>
																											<xsl:if test="Data">
																												<span class="valore">
																													<xsl:call-template name="FormatDateSmart">
																														<xsl:with-param name="DateTime" select="Data" />
																													</xsl:call-template>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">ID voce doc.</span>
																											<xsl:if test="NumItem">
																												<span class="valore">
																													<xsl:value-of select="NumItem"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Cod comm./conv.</span>
																											<xsl:if test="CodiceCommessaConvenzione">
																												<span class="valore">
																													<xsl:value-of select="CodiceCommessaConvenzione"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CIG</span>
																											<xsl:if test="CodiceCIG">
																												<span class="valore">
																													<xsl:value-of select="CodiceCIG"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CUP</span>
																											<xsl:if test="CodiceCUP">
																												<span class="valore">
																													<xsl:value-of select="CodiceCUP"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Rif. righe fatt.</span>
																											<xsl:if test="RiferimentoNumeroLinea">
																												<div class="valore list-container">
																													<xsl:choose>
																														<xsl:when test="count(RiferimentoNumeroLinea) = $NUMERO_LINEE">
																															Tutte
																														</xsl:when>
																														<xsl:otherwise>
																															<xsl:for-each select="RiferimentoNumeroLinea">
																																<xsl:variable name="rif" select="." />
																																<span class="list"><xsl:value-of select="$rif"/></span>
																															</xsl:for-each>
																														</xsl:otherwise>
																													</xsl:choose>
																												</div>
																											</xsl:if>
																										</td>
																									</tr>
																									<tr class="eTableSubRow"><td colspan="8" class="low-padding"></td></tr>
																								</xsl:for-each>
																								<xsl:for-each select="DatiGenerali/DatiContratto">
																									<tr class="eTableRow">
																										<td>
																											<span class="chiave">Tipo doc.</span>
																											<span class="valore">Dati contratto</span>
																										</td>
																										<td>
																											<span class="chiave">Numero doc.</span>
																											<xsl:if test="IdDocumento">
																												<span class="valore">
																													<xsl:value-of select="IdDocumento"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Data doc.</span>
																											<xsl:if test="Data">
																												<span class="valore">
																													<xsl:call-template name="FormatDateSmart">
																														<xsl:with-param name="DateTime" select="Data" />
																													</xsl:call-template>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">ID voce doc.</span>
																											<xsl:if test="NumItem">
																												<span class="valore">
																													<xsl:value-of select="NumItem"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Cod comm./conv</span>
																											<xsl:if test="CodiceCommessaConvenzione">
																												<span class="valore">
																													<xsl:value-of select="CodiceCommessaConvenzione"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CIG</span>
																											<xsl:if test="CodiceCIG">
																												<span class="valore">
																													<xsl:value-of select="CodiceCIG"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CUP</span>
																											<xsl:if test="CodiceCUP">
																												<span class="valore">
																													<xsl:value-of select="CodiceCUP"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Rif. righe fatt.</span>
																											<xsl:if test="RiferimentoNumeroLinea">
																												<div class="valore list-container">
																													<xsl:choose>
																														<xsl:when test="count(RiferimentoNumeroLinea) = $NUMERO_LINEE">
																															Tutte
																														</xsl:when>
																														<xsl:otherwise>
																															<xsl:for-each select="RiferimentoNumeroLinea">
																																<xsl:variable name="rif" select="." />
																																<span class="list"><xsl:value-of select="$rif"/></span>
																															</xsl:for-each>
																														</xsl:otherwise>
																													</xsl:choose>
																												</div>
																											</xsl:if>
																										</td>
																									</tr>
																									<tr class="eTableSubRow"><td colspan="8" class="low-padding"></td></tr>
																								</xsl:for-each>
																								<xsl:for-each select="DatiGenerali/DatiConvenzione">
																									<tr class="eTableRow">
																										<td>
																											<span class="chiave">Tipo doc.</span>
																											<span class="valore">Dati convenzione</span>
																										</td>
																										<td>
																											<span class="chiave">Numer doc.</span>
																											<xsl:if test="IdDocumento">
																												<span class="valore">
																													<xsl:value-of select="IdDocumento"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Data doc.</span>
																											<xsl:if test="Data">
																												<span class="valore">
																													<xsl:call-template name="FormatDateSmart">
																														<xsl:with-param name="DateTime" select="Data" />
																													</xsl:call-template>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">ID voce doc.</span>
																											<xsl:if test="NumItem">
																												<span class="valore">
																													<xsl:value-of select="NumItem"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Cod. comm./conv.</span>
																											<xsl:if test="CodiceCommessaConvenzione">
																												<span class="valore">
																													<xsl:value-of select="CodiceCommessaConvenzione"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CIG</span>
																											<xsl:if test="CodiceCIG">
																												<span class="valore">
																													<xsl:value-of select="CodiceCIG"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CUP</span>
																											<xsl:if test="CodiceCUP">
																												<span class="valore">
																													<xsl:value-of select="CodiceCUP"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Rif. righe fatt.</span>
																											<xsl:if test="RiferimentoNumeroLinea">
																												<div class="valore list-container">
																													<xsl:choose>
																														<xsl:when test="count(RiferimentoNumeroLinea) = $NUMERO_LINEE">
																															Tutte
																														</xsl:when>
																														<xsl:otherwise>
																															<xsl:for-each select="RiferimentoNumeroLinea">
																																<xsl:variable name="rif" select="." />
																																<span class="list"><xsl:value-of select="$rif"/></span>
																															</xsl:for-each>
																														</xsl:otherwise>
																													</xsl:choose>
																												</div>
																											</xsl:if>
																										</td>
																									</tr>
																									<tr class="eTableSubRow"><td colspan="8" class="low-padding"></td></tr>
																								</xsl:for-each>
																								<xsl:for-each select="DatiGenerali/DatiRicezione">
																									<tr class="eTableRow">
																										<td>
																											<span class="chiave">Tipo doc.</span>
																											<span class="valore">Dati ricezione</span>
																										</td>
																										<td>
																											<span class="chiave">Numero doc.</span>
																											<xsl:if test="IdDocumento">
																												<span class="valore">
																													<xsl:value-of select="IdDocumento"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Data doc.</span>
																											<xsl:if test="Data">
																												<span class="valore">
																													<xsl:call-template name="FormatDateSmart">
																														<xsl:with-param name="DateTime" select="Data" />
																													</xsl:call-template>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">ID voce doc.</span>
																											<xsl:if test="NumItem">
																												<span class="valore">
																													<xsl:value-of select="NumItem"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Cod. comm./conv.</span>
																											<xsl:if test="CodiceCommessaConvenzione">
																												<span class="valore">
																													<xsl:value-of select="CodiceCommessaConvenzione"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CIG</span>
																											<xsl:if test="CodiceCIG">
																												<span class="valore">
																													<xsl:value-of select="CodiceCIG"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CUP</span>
																											<xsl:if test="CodiceCUP">
																												<span class="valore">
																													<xsl:value-of select="CodiceCUP"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Rif. righe fatt.</span>
																											<xsl:if test="RiferimentoNumeroLinea">
																												<div class="valore list-container">
																													<xsl:choose>
																														<xsl:when test="count(RiferimentoNumeroLinea) = $NUMERO_LINEE">
																															Tutte
																														</xsl:when>
																														<xsl:otherwise>
																															<xsl:for-each select="RiferimentoNumeroLinea">
																																<xsl:variable name="rif" select="." />
																																<span class="list"><xsl:value-of select="$rif"/></span>
																															</xsl:for-each>
																														</xsl:otherwise>
																													</xsl:choose>
																												</div>
																											</xsl:if>
																										</td>
																									</tr>
																									<tr class="eTableSubRow"><td colspan="8" class="low-padding"></td></tr>
																								</xsl:for-each>
																								<xsl:for-each select="DatiGenerali/DatiFattureCollegate">
																									<tr class="eTableRow">
																										<td>
																											<span class="chiave">Tipo doc.</span>
																											<span class="valore">Dati fatture collegate</span>
																										</td>
																										<td>
																											<span class="chiave">Numero doc.</span>
																											<xsl:if test="IdDocumento">
																												<span class="valore">
																													<xsl:value-of select="IdDocumento"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Data doc.</span>
																											<xsl:if test="Data">
																												<span class="valore">
																													<xsl:call-template name="FormatDateSmart">
																														<xsl:with-param name="DateTime" select="Data" />
																													</xsl:call-template>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">ID voce doc.</span>
																											<xsl:if test="NumItem">
																												<span class="valore">
																													<xsl:value-of select="NumItem"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Cod. comm./conv.</span>
																											<xsl:if test="CodiceCommessaConvenzione">
																												<span class="valore">
																													<xsl:value-of select="CodiceCommessaConvenzione"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CIG</span>
																											<xsl:if test="CodiceCIG">
																												<span class="valore">
																													<xsl:value-of select="CodiceCIG"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">CUP</span>
																											<xsl:if test="CodiceCUP">
																												<span class="valore">
																													<xsl:value-of select="CodiceCUP"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Rif. righe fatt</span>
																											<xsl:if test="RiferimentoNumeroLinea">
																												<div class="valore list-container">
																													<xsl:choose>
																														<xsl:when test="count(RiferimentoNumeroLinea) = $NUMERO_LINEE">
																															Tutte
																														</xsl:when>
																														<xsl:otherwise>
																															<xsl:for-each select="RiferimentoNumeroLinea">
																																<xsl:variable name="rif" select="." />
																																<span class="list"><xsl:value-of select="$rif"/></span>
																															</xsl:for-each>
																														</xsl:otherwise>
																													</xsl:choose>
																												</div>
																											</xsl:if>
																										</td>
																									</tr>
																									<tr class="eTableSubRow"><td colspan="8" class="low-padding"></td></tr>
																								</xsl:for-each>
																								<xsl:for-each select="DatiGenerali/DatiDDT">
																									<tr class="eTableRow">
																										<td>
																											<span class="chiave">Tipo doc.</span>
																											<span class="valore">Dati DDT</span>
																										</td>
																										<td>
																											<span class="chiave">Numero doc.</span>
																											<xsl:if test="NumeroDDT">
																												<span class="valore">
																													<xsl:value-of select="NumeroDDT"/>
																												</span>
																											</xsl:if>
																										</td>
																										<td colspan="5">
																											<span class="chiave">Data doc.</span>
																											<xsl:if test="DataDDT">
																												<span class="valore">
																													<xsl:call-template name="FormatDateSmart">
																														<xsl:with-param name="DateTime" select="DataDDT" />
																													</xsl:call-template>
																												</span>
																											</xsl:if>
																										</td>
																										<td>
																											<span class="chiave">Rif. righe fatt.</span>
																											<xsl:if test="RiferimentoNumeroLinea">
																												<div class="valore list-container">
																													<xsl:choose>
																														<xsl:when test="count(RiferimentoNumeroLinea) = $NUMERO_LINEE">
																															Tutte
																														</xsl:when>
																														<xsl:otherwise>
																															<xsl:for-each select="RiferimentoNumeroLinea">
																																<xsl:variable name="rif" select="." />
																																<span class="list"><xsl:value-of select="$rif"/></span>
																															</xsl:for-each>
																														</xsl:otherwise>
																													</xsl:choose>
																												</div>
																											</xsl:if>
																										</td>
																									</tr>
																									<tr class="eTableSubRow"><td colspan="8" class="low-padding"></td></tr>
																								</xsl:for-each>
																							</tbody>
																						</table>
																					</div>
																				</div>
																			</td>
																		</tr>
																	</xsl:if>

																	<xsl:call-template name="PrintSezionePostDocumentiCorrelati">
																		<xsl:with-param name="nodeList" select="."/>
																	</xsl:call-template>

																</tbody>
															</table>

															<div class="hline"></div>
														</xsl:if>

														<div class="sezione">
															<!-- CALCOLI-->
															<xsl:variable name="TOTALE_NETTO">
																<xsl:if test="DatiBeniServizi">
																	<xsl:if test="DatiBeniServizi/DettaglioLinee">
																		<xsl:call-template name="ComputePrezzoTotale">
																			<xsl:with-param name="nodeList" select="DatiBeniServizi/DettaglioLinee" />
																			<xsl:with-param name="totalSoFar" select="0" />
																		</xsl:call-template>
																	</xsl:if>
																</xsl:if>
															</xsl:variable>

															<xsl:variable name="TOTALE_IMPOSTA_CALCOLATA">
																<xsl:choose>
																	<xsl:when test="DatiBeniServizi/DatiRiepilogo">
																		<xsl:call-template name="ComputeTotaleImposta">
																			<xsl:with-param name="nodeList" select="DatiBeniServizi/DatiRiepilogo" />
																			<xsl:with-param name="totalSoFar" select="0" />
																		</xsl:call-template>
																	</xsl:when>
																	<xsl:otherwise>
																		0
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:variable>

															<xsl:variable name="TOTALE_IMPONIBILE_CALCOLATO">
																<xsl:choose>
																	<xsl:when test="DatiBeniServizi/DatiRiepilogo">
																		<xsl:call-template name="ComputeTotaleImponibile">
																			<xsl:with-param name="nodeList" select="DatiBeniServizi/DatiRiepilogo" />
																			<xsl:with-param name="totalSoFar" select="0" />
																		</xsl:call-template>
																	</xsl:when>
																	<xsl:otherwise>
																		0
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:variable>

															<xsl:variable name="NETTO_A_PAGARE">
																<xsl:call-template name="ComputeNettoAPagare">
																	<xsl:with-param name="nodeList" select="DatiPagamento/DettaglioPagamento" />
																	<xsl:with-param name="totalSoFar" select="0" />
																</xsl:call-template>
															</xsl:variable>

															<xsl:variable name="formatOut">0,00######</xsl:variable>

															<div class="block">
																<div class="sectionHeader">Riepilogo IVA</div>
																<xsl:if test="DatiBeniServizi/DatiRiepilogo">
																	<table class="tableDesktop eTable normal">
																		<thead class="eTableHeadGrey">
																			<tr>
																				<th class="truncate center" style="width: 8%;"><span>IVA</span></th>
																				<th class="truncate center" style="width: 16%;"><span>Natura</span></th>
																				<th class="truncate" style="width: 22%">Normativa</th>
																				<th class="truncate" style="width: 20%;"><span>Esigibilit&#224;</span></th>
																				<th class="truncate importo" style="width: 19%;"><span>Imponibile</span></th>
																				<th class="truncate importo" style="width: 15%;"><span>Imposta</span></th>
																			</tr>
																		</thead>
																		<tbody>
																			<xsl:for-each select="DatiBeniServizi/DatiRiepilogo">
																				<tr class="eTableRow">
																					<xsl:variable name="aliquotaClass">
																						<xsl:if test="not(AliquotaIVA)">
																							hide
																						</xsl:if>
																					</xsl:variable>
																					<td class="importo {$aliquotaClass}">
																						<span class="chiave">IVA</span>
																						<xsl:if test="AliquotaIVA">
																							<span class="valore">
																								<xsl:value-of select="format-number(AliquotaIVA, '0,00', 'euroFormat')"/>%
																							</span>
																						</xsl:if>
																					</td>

																					<xsl:variable name="natClass">
																						<xsl:if test="not(Natura)">
																							hide
																						</xsl:if>
																					</xsl:variable>
																					<td class="center {$natClass}">
																						<span class="chiave">Natura</span>
																						<xsl:if test="Natura">
																							<span class="valore">
																								<xsl:value-of select="Natura"/>
																							</span>
																						</xsl:if>
																					</td>
																					<td class="{$natClass}">
																						<span class="chiave">Normativa</span>
																						<span class="valore">
																							<xsl:value-of select="RiferimentoNormativo" />
																						</span>
																					</td>

																					<xsl:variable name="esigibilitaClass">
																						<xsl:if test="not(EsigibilitaIVA)">
																							hide
																						</xsl:if>
																					</xsl:variable>
																					<td class="{$esigibilitaClass}">
																						<span class="chiave">Esigibilit&#224;</span>
																						<xsl:if test="EsigibilitaIVA">
																							<span class="valore">
																								<xsl:choose>
																									<xsl:when test="EsigibilitaIVA = 'D'">
																										Differita
																									</xsl:when>
																									<xsl:when test="EsigibilitaIVA = 'I'">
																										Immediata
																									</xsl:when>
																									<xsl:when test="EsigibilitaIVA = 'S'">
																										Scissione dei pagamenti
																									</xsl:when>
																									<xsl:otherwise>
																										!!!(codice non riconosciuto)!!!
																									</xsl:otherwise>
																								</xsl:choose>
																							</span>
																						</xsl:if>
																					</td>

																					<xsl:variable name="imponibileClass">
																						<xsl:if test="not(ImponibileImporto)">
																							hide
																						</xsl:if>
																					</xsl:variable>
																					<td class="{$imponibileClass} importo-right">
																						<span class="chiave">Imponibile</span>
																						<xsl:if test="ImponibileImporto">
																							<span class="valore">
																								<xsl:value-of select="format-number(ImponibileImporto, '0,00', 'euroFormat')"/>&#160;&#8364;
																							</span>
																						</xsl:if>
																					</td>

																					<xsl:variable name="impostaClass">
																						<xsl:if test="not(Imposta)">
																							hide
																						</xsl:if>
																					</xsl:variable>
																					<td class="{$impostaClass} importo-right">
																						<span class="chiave">Imposta</span>
																						<xsl:if test="Imposta">
																							<span class="valore">
																								<xsl:value-of select="format-number(Imposta, '0,00', 'euroFormat')"/>&#160;&#8364;
																							</span>
																						</xsl:if>
																					</td>
																				</tr>
																				<tr class="eTableSubRow"><td colspan="6" class="low-padding"></td></tr>
																			</xsl:for-each>
																		</tbody>
																	</table>
																</xsl:if>
															</div>

															<div class="block fattura">
																<div class="sectionHeader">Calcolo fattura</div>
																<table class="eTable">
																	<xsl:if test="DatiPagamento/DettaglioPagamento">
																		<tfoot>
																			<tr>
																				<th style="width: 60%; font-weight: normal; text-transform: none">
																					Netto a pagare
																				</th>
																				<th style="text-align: right; font-weight: bold;">
																					<xsl:copy-of select="format-number($NETTO_A_PAGARE, '0,00', 'euroFormat')" />&#160;&#8364;
																				</th>
																			</tr>
																		</tfoot>
																	</xsl:if>
																	<tbody>
																		<tr>
																			<td>Importo prodotti o servizi</td>
																			<td style="text-align: right;">
																				<xsl:value-of select="format-number($NETTO_A_PAGARE, $formatOut, 'euroFormat')"/>&#160;&#8364;
																			</td>
																		</tr>
																		<xsl:if test="DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale">
																			<xsl:for-each select="DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale">
																				<xsl:variable name="TC">
																					<xsl:value-of select="TipoCassa" />
																				</xsl:variable>
																				<tr>
																					<td>
																						Cassa <xsl:copy-of select="position()" />
																						<xsl:choose>
																							<xsl:when test="$TC='TC01'">
																								(CASSAFORENSE)
																							</xsl:when>
																							<xsl:when test="$TC='TC02'">
																								(CNPADC)
																							</xsl:when>
																							<xsl:when test="$TC='TC03'">
																								(CIPAG)
																							</xsl:when>
																							<xsl:when test="$TC='TC04'">
																								(INARCASSA)
																							</xsl:when>
																							<xsl:when test="$TC='TC05'">
																								(CNN)
																							</xsl:when>
																							<xsl:when test="$TC='TC06'">
																								(CNPR)
																							</xsl:when>
																							<xsl:when test="$TC='TC07'">
																								(ENASARCO)
																							</xsl:when>
																							<xsl:when test="$TC='TC08'">
																								(ENPACL)
																							</xsl:when>
																							<xsl:when test="$TC='TC09'">
																								(ENPAM)
																							</xsl:when>
																							<xsl:when test="$TC='TC10'">
																								(ENPAF)
																							</xsl:when>
																							<xsl:when test="$TC='TC11'">
																								(ENPAV)
																							</xsl:when>
																							<xsl:when test="$TC='TC12'">
																								(ENPAIA)
																							</xsl:when>
																							<xsl:when test="$TC='TC13'">
																								(FASC)
																							</xsl:when>
																							<xsl:when test="$TC='TC14'">
																								(INPGI)
																							</xsl:when>
																							<xsl:when test="$TC='TC15'">
																								(ONAOSI)
																							</xsl:when>
																							<xsl:when test="$TC='TC16'">
																								(CASAGIT)
																							</xsl:when>
																							<xsl:when test="$TC='TC17'">
																								(EPPI)
																							</xsl:when>
																							<xsl:when test="$TC='TC18'">
																								(EPAP)
																							</xsl:when>
																							<xsl:when test="$TC='TC19'">
																								(ENPAB)
																							</xsl:when>
																							<xsl:when test="$TC='TC20'">
																								(ENPAPI)
																							</xsl:when>
																							<xsl:when test="$TC='TC21'">
																								(ENPAP)
																							</xsl:when>
																							<xsl:when test="$TC='TC22'">
																								(INPS)
																							</xsl:when>
																							<xsl:when test="$TC=''"></xsl:when>
																							<xsl:otherwise>
																								<span>(!!! codice non previsto !!!)</span>&#160;
																							</xsl:otherwise>
																						</xsl:choose>
																					</td>
																					<td style="text-align: right;">
																						<xsl:value-of select="format-number(ImportoContributoCassa, $formatOut, 'euroFormat')"/>&#160;&#8364;
																					</td>
																				</tr>
																			</xsl:for-each>
																		</xsl:if>
																		<tr>
																			<td>Totale imponibile</td>
																			<td style="text-align: right;">
																				<xsl:value-of select="format-number($TOTALE_IMPONIBILE_CALCOLATO, $formatOut, 'euroFormat')"/>&#160;&#8364;
																			</td>
																		</tr>

																		<xsl:variable name="nodiRiepilogo" select="DatiBeniServizi/DatiRiepilogo" />
																		<xsl:for-each select="document('')/*/xsl:variable[@name='natureList']/Item">
																			<xsl:variable name="importoN">
																				<xsl:call-template name="ComputeTotaleNatura">
																					<xsl:with-param name="tipo" select="Tipo"/>
																					<xsl:with-param name="nodeList" select="$nodiRiepilogo" />
																					<xsl:with-param name="totalSoFar" select="0" />
																				</xsl:call-template>
																			</xsl:variable>

																			<xsl:if test="$importoN > 0">
																				<tr>
																					<td>
																						<xsl:value-of select="Label" /> (<xsl:value-of select="Tipo" />)
																					</td>
																					<td style="text-align: right;">
																						<xsl:value-of select="format-number($importoN, $formatOut, 'euroFormat')"/>&#160;&#8364;
																					</td>
																				</tr>
																			</xsl:if>
																		</xsl:for-each>

																		<tr>
																			<td>Totale IVA</td>
																			<td style="text-align: right;">
																				<xsl:value-of select="format-number($TOTALE_IMPOSTA_CALCOLATA, $formatOut, 'euroFormat')"/>&#160;&#8364;
																			</td>
																		</tr>

																		<xsl:if test="DatiGenerali/DatiGeneraliDocumento/ImportoTotaleDocumento">
																			<tr style="font-weight: bold">
																				<td>
																					Totale documento
																				</td>
																				<td style="text-align: right;">
																					<xsl:value-of select="format-number(DatiGenerali/DatiGeneraliDocumento/ImportoTotaleDocumento, $formatOut, 'euroFormat')"/>&#160;&#8364;
																				</td>
																			</tr>
																		</xsl:if>

																		<xsl:if test="DatiGenerali/DatiGeneraliDocumento/DatiRitenuta">
																			<xsl:variable name="importoRitenutaAcconto">
																				<xsl:call-template name="ComputeImportoRitenutaAcconto">
																					<xsl:with-param name="nodeList" select="DatiGenerali/DatiGeneraliDocumento/DatiRitenuta"/>
																					<xsl:with-param name="totalSoFar" select="0"/>
																				</xsl:call-template>
																			</xsl:variable>

																			<xsl:if test="$importoRitenutaAcconto > 0">
																				<tr>
																					<td>
																						Importo ritenuta d'acconto
																					</td>
																					<td style="text-align: right;">
																						-<xsl:value-of select="format-number($importoRitenutaAcconto, $formatOut, 'euroFormat')"/>&#160;&#8364;
																					</td>
																				</tr>
																			</xsl:if>

																			<xsl:variable name="nodiRitenuta" select="DatiGenerali/DatiGeneraliDocumento/DatiRitenuta" />
																			<xsl:for-each select="document('')/*/xsl:variable[@name='ritenutaPrevList']/Item">
																				<xsl:variable name="importoN">
																					<xsl:call-template name="ComputeImportoRitenutaPrevidenziale">
																						<xsl:with-param name="tipo" select="Tipo"/>
																						<xsl:with-param name="nodeList" select="$nodiRitenuta" />
																						<xsl:with-param name="totalSoFar" select="0" />
																					</xsl:call-template>
																				</xsl:variable>

																				<xsl:if test="$importoN > 0">
																					<tr>
																						<td>
																							Importo ritenuta previdenziale (<xsl:value-of select="Label" />)
																						</td>
																						<td style="text-align: right;">
																							-<xsl:value-of select="format-number($importoN, $formatOut, 'euroFormat')"/>&#160;&#8364;
																						</td>
																					</tr>
																				</xsl:if>
																			</xsl:for-each>
																		</xsl:if>

																		<xsl:if test="DatiGenerali/DatiGeneraliDocumento/ScontoMaggiorazione">
																			<xsl:choose>
																				<xsl:when test="DatiGenerali/DatiGeneraliDocumento/ImportoTotaleDocumento">
																					<xsl:call-template name="ComputeScontiMaggiorazione">
																						<xsl:with-param name="nodeList" select="DatiGenerali/DatiGeneraliDocumento/ScontoMaggiorazione"/>
																						<xsl:with-param name="totalSoFar" select="DatiGenerali/DatiGeneraliDocumento/ImportoTotaleDocumento"/>
																						<xsl:with-param name="formatOut" select="$formatOut"/>
																					</xsl:call-template>
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:for-each select="DatiGenerali/DatiGeneraliDocumento/ScontoMaggiorazione">
																						<tr>
																							<td>
																								<xsl:choose>
																									<xsl:when test="Tipo = 'SC'">
																										Sconto
																									</xsl:when>
																									<xsl:otherwise>
																										Maggiorazione
																									</xsl:otherwise>
																								</xsl:choose>
																								<xsl:if test="Percentuale">
																									&#160;<xsl:copy-of select="format-number(Percentuale, '0,00', 'euroFormat')" />%
																								</xsl:if>
																							</td>
																							<td style="text-align: right;">
																								<xsl:if test="Importo">
																									<Value>
																										<xsl:if test="Tipo = 'SC'">-</xsl:if><xsl:value-of select="format-number(Importo, $formatOut, 'euroFormat')"/>&#160;&#8364;
																									</Value>
																								</xsl:if>
																							</td>
																						</tr>
																					</xsl:for-each>
																				</xsl:otherwise>
																			</xsl:choose>
																		</xsl:if>

																		<xsl:if test="DatiGenerali/DatiGeneraliDocumento/Arrotondamento">
																			<tr>
																				<td>
																					Arrotondamento
																				</td>
																				<td style="text-align: right;">
																					<xsl:value-of select="format-number(DatiGenerali/DatiGeneraliDocumento/Arrotondamento, $formatOut, 'euroFormat')"/>&#160;&#8364;
																				</td>
																			</tr>
																		</xsl:if>
																	</tbody>
																</table>
															</div>
														</div>
													</div>
												</td>
											</tr>
										</tbody>
									</table>
									<div class="report-footer out-table">
										<xsl:copy-of select="$PAGE_FOOTER"/>
									</div>
								</div>
							</xsl:for-each>
							<!--FINE BODY-->
					</xsl:if>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
