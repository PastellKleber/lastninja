<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">

	<xsl:output method="html" indent="yes" encoding="UTF-8" doctype-system="about:legacy-compat"/>
	<xsl:strip-space elements="*"/>
	<xsl:key name="notes-by-id" match="note" use="@xml:id"/>
	<xsl:key name="graphics-by-id" match="graphic" use="@xml:id"/>

    <xsl:include href="htmlTemplates.xsl"/>

	<xsl:template match="/">
		<xsl:result-document byte-order-mark="yes"
			href="lastninja1.html">
			<html>
				<head>
					<title>
						<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
					</title>
					<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
					<link href="lastninja1.css" rel="stylesheet" type="text/css"/>
				</head>
				<body>		
					<xsl:apply-templates select="TEI/text/front"/>			
					<xsl:call-template name="emulator"/>
					
					<xsl:apply-templates select="TEI/text/body"/>
					<xsl:apply-templates select="TEI/text/back"/>
					
					<!-- JavaScript für den Emulator-Toggle und TOC-Toggle und Musik -->
					<script>
						                        <![CDATA[
                        //JavaScript für den Emulator-Toggle und TOC-Toggle
                        document.addEventListener('DOMContentLoaded', function() {
                            const emulatorToggleButton = document.getElementById('emulator-button');
                            const emulatorContainer = document.getElementById('emulator-container');

                            if (emulatorToggleButton && emulatorContainer) {
                                emulatorToggleButton.addEventListener('click', function() {
                                    emulatorContainer.classList.toggle('closed');
                                    if (emulatorContainer.classList.contains('closed')) {
                                        emulatorToggleButton.textContent = '+';
                                    } else {
                                        emulatorToggleButton.textContent = '–';
                                    }
                                });
                            } else {
                                console.warn('Emulator Toggle: Button or Container not found. Check your IDs!');
                            }

                            const tocToggleButton = document.getElementById('toc-button');
                            const tocContainer = document.getElementById('toc-container');
                            const tocContent = document.getElementById('toc-content');

                            if (tocToggleButton && tocContainer && tocContent) {
                                tocToggleButton.addEventListener('click', function() {
                                    tocContent.classList.toggle('closed');
                                    tocContainer.classList.toggle('closed');

                                    if (tocContent.classList.contains('closed')) {
                                        tocToggleButton.textContent = '+';
                                    } else {
                                        tocToggleButton.textContent = '–';
                                    }
                                });
                            } else {
                                console.warn('TOC Toggle: Button or Container/Content not found. Check your IDs!');
                            }

                            // JavaScript für Musik-Player in Überschriften
                            const playPauseButtons = document.querySelectorAll('.play-pause-button');

                            playPauseButtons.forEach(button => {
                                button.addEventListener('click', function() {
                                    const audioId = this.dataset.audioId;
                                    const audioPlayer = document.getElementById('audio-' + audioId);

                                    if (audioPlayer) {
                                        if (audioPlayer.paused) {
                                            // Alle anderen Audio-Player pausieren
                                            document.querySelectorAll('.audio-player').forEach(player => {
                                                if (player !== audioPlayer && !player.paused) {
                                                    player.pause();
                                                    const otherButton = document.querySelector(`[data-audio-id="${player.id.replace('audio-', '')}"]`);
                                                    if (otherButton) {
                                                        otherButton.textContent = '▶';
                                                    }
                                                }
                                            });

                                            audioPlayer.play()
                                                .then(() => {
                                                    this.textContent = '⏸'; // Button-Text auf Pause setzen
                                                    console.log(`Audio ${audioId} wird abgespielt.`);
                                                })
                                                .catch(error => {
                                                    console.error(`Fehler beim Abspielen von Audio ${audioId}:`, error);
                                                    alert('Autoplay blockiert oder Fehler beim Laden des Audios. Bitte klicken Sie erneut oder prüfen Sie die URL.');
                                                });
                                        } else {
                                            audioPlayer.pause();
                                            this.textContent = '▶'; // Button-Text auf Play setzen
                                            console.log(`Audio ${audioId} pausiert.`);
                                        }
                                    }
                                });

                                // Event-Listener, wenn der Track zu Ende ist
                                const audioPlayer = document.getElementById('audio-' + button.dataset.audioId);
                                if (audioPlayer) {
                                    audioPlayer.addEventListener('ended', function() {
                                        button.textContent = '▶'; // Button auf Play zurücksetzen
                                    });
                                }
                            });
                        });
                        ]]>
                    </script>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>

<!-- Implementierung iframe -->
	<xsl:template name="emulator">
		<div id="emulator-container" class="open">
			<button id="emulator-button">–</button>
			<iframe id="emulator" src="https://c64.krissz.hu/last-ninja-i/play-online/">
			</iframe>
		</div>
	</xsl:template>

<!-- Inhaltsverzeichnis -->
	<xsl:template match="ab[@rend='toc']">
		<nav id="toc-container" class="open"> <div class="toc-header">
			<h2 class="toc-title">Inhaltsverzeichnis</h2>
			<button id="toc-button" class="toc-button">–</button>
		</div>
			<div id="toc-content" class="toc-links">
				<xsl:apply-templates select="ref | lb | cb"/>
			</div>
		</nav>
	</xsl:template>
	
	<xsl:template match="ab[@rend='toc']/ref" priority="2 ">
		<a href="{@target}" class="toc-link">
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="ab[@rend='toc']/lb">
		<br/>
	</xsl:template>

	<!-- TEI figure -->

	<xsl:template match="figure">
		<xsl:variable name="image_id" select="substring-after(@facs, '#')"/>
		<xsl:variable name="image_url" select="key('graphics-by-id', $image_id)/@url"/>
		
		<figure>
			<xsl:if test="@rend">
				<xsl:attribute name="class">
					<xsl:value-of select="@rend"/>
				</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="$image_url != ''">
				<img src="{$image_url}">
					<xsl:if test="@rend">
						<xsl:attribute name="class">
							<xsl:value-of select="@rend"/>
						</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:if>
			
			<xsl:apply-templates select="desc"/>
		</figure>
	</xsl:template>
	
	<xsl:template match="figure/desc">
		<figcaption>
			<xsl:if test="@rend">
				<xsl:attribute name="class">
					<xsl:value-of select="@rend"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</figcaption>
	</xsl:template>
	
	<xsl:template match="figure[@rend='youtube']">
		<div class="video-container">
			<iframe width="560" height="315"
				src="https://www.youtube-nocookie.com/embed/{graphic/@url}"
				title="YouTube video player"
				frameborder="0"
				allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
				referrerpolicy="strict-origin-when-cross-origin"
				allowfullscreen="allowfullscreen">
			</iframe>
		</div>
	</xsl:template>

<!--  TEI Anonymopus block  -->
    
    <xsl:template match="TEI/text//ab[@type='boxDrawing']">
        <span class="{@rend}" data-tei="ab">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
<!-- TEI hi Element-->
    
    <xsl:template match="TEI/text//hi">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'widespace')">
                <!-- Sonderbehandlung von Sperrungen -->
                <xsl:variable name="charBefore"
                    select="substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]))"/>
                <xsl:variable name="charAfter"
                    select="substring(following-sibling::text()[1], 1, 1)"/>
                <span data-tei="hi">
                    <xsl:attribute name="class">
                        <xsl:value-of select="@rend"/>
                        <xsl:text> </xsl:text>
                        <!-- widespaceBefore bei vorausgehendem Spatium -->
                        <xsl:if test="contains(' ', $charBefore)">
                            <xsl:text> widespaceBefore</xsl:text>
                        </xsl:if>
                        <!-- noWidespaceAfter bei anschließenden (kleinen) Satzzeichen -->
                        <xsl:if test="contains(',.“', $charAfter)">
                            <xsl:text> noWidespaceAfter</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{@rend}" data-tei="hi">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

	<!-- CONCEPTIONAL ITEMS, division layer -->

	<!-- TEI front -->
	<xsl:template match="TEI/text/front">
		<header data-tei="front">
			<xsl:apply-templates/>
		</header>
	</xsl:template>
	

	<!-- TEI body -->
	<xsl:template match="TEI/text/body">
		<!-- HTML-Seitentext -->
		<article data-tei="body">
			<xsl:apply-templates/>
		</article>
	</xsl:template>

	<!-- TEI back -->
	<xsl:template match="TEI/text/back">
		<footer data-tei="back">
			<xsl:apply-templates select="*[not(self::note)]"/>
		</footer>
	</xsl:template>

	<!-- TEI division -->
	<xsl:template match="TEI/text//div">
		<div class="div{count(ancestor::div)+1}" data-tei="div">
			<xsl:apply-templates select="@xml:id | node()"/>
		</div>
	</xsl:template>

	<!-- TEI division ids -->
	<xsl:template match="TEI/text//div/@xml:id">
		<xsl:attribute name="id" select="."/>
	</xsl:template>


	<!-- CONCEPTIONAL ITEMS, block layer -->

	<!-- TEI header -->

	<xsl:template match="TEI/text//head[@type]">
		        <div class="audio-container">
			            <xsl:element name="{@type}">
				                <xsl:attribute name="data-tei" select="'head'"/>
				<xsl:if test="@xml:id">
					<xsl:attribute name="id" select="@xml:id"/>
				</xsl:if>
				<xsl:if test="@rend">
					<xsl:attribute name="class">
						<xsl:value-of select="@rend"/>
					</xsl:attribute>
				</xsl:if>
				      <xsl:apply-templates select="node()[not(self::media)]"/>
				            </xsl:element>
			                        <xsl:if test="media[@mimeType='audio/mpeg']/@url and @xml:id">
				                <button class="play-pause-button" data-audio-id="{@xml:id}">▶</button>
				                <audio class="audio-player" id="audio-{@xml:id}" preload="none">
					                    <xsl:attribute name="src">
						                        <xsl:value-of select="media[@mimeType='audio/mpeg']/@url"/>
						                    </xsl:attribute>
					                    <xsl:attribute name="type">audio/mpeg</xsl:attribute>
					                </audio>
				            </xsl:if>
			            <xsl:if test="@facs and id(substring(@facs,2))/@url">
				                <img src="{id(substring(@facs,2))/@url}"/>
				            </xsl:if>
			        </div>
		    </xsl:template>

	<!-- TEI header -->

	<xsl:template match="TEI/text//head[not(@type)]">
		        <div class="audio-container">
			            <h3 data-tei="head">
				<xsl:if test="@xml:id">
					<xsl:attribute name="id" select="@xml:id"/>
				</xsl:if>
				<xsl:if test="@rend">
					<xsl:attribute name="class">
						<xsl:value-of select="@rend"/>
					</xsl:attribute>
				</xsl:if>
				                <xsl:apply-templates select="node()[not(self::media)]"/>
				            </h3>
			                        <xsl:if test="media[@mimeType='audio/mpeg']/@url and @xml:id">
				<button class="play-pause-button" data-audio-id="{@xml:id}">▶</button>
				<audio class="audio-player" id="audio-{@xml:id}" preload="none"
					src="{media[@mimeType='audio/mpeg']/@url}"
					type="audio/mpeg">
					Dein Browser unterstützt das Audio-Element nicht.
				</audio>
			</xsl:if>
			        </div>
		    </xsl:template>
	
	<!-- TEI paragraph -->
	<xsl:template match="TEI/text//p">
		<p data-tei="p">
			<xsl:apply-templates select="@rend | node()"/>
		</p>
	</xsl:template>

	<!-- TEI span -->
	<xsl:template match="TEI/text//span">
		<span data-tei="span">
			<xsl:apply-templates select="@rend | node()"/>
		</span>
	</xsl:template>

	<!-- TEI rendition -->

	<xsl:template match="@rend[not(parent::head)]">
		<xsl:attribute name="class">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	
	<!-- Allgemeine <ref>-Verlinkung im Text -->
	<xsl:template match="ref[@target]" priority="1">
		<a href="{@target}">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- TOPOGRAPHIC ITEMS, generic -->

	<!-- TEI page beginning, in paragraph -->
	<xsl:template match="TEI/text//p//pb">
		<xsl:if test="following::lb[1]/@break = 'yes' or not(following::lb[1]/@break)">
			<xsl:text></xsl:text>
		</xsl:if>
		<span class="editorialMark" data-tei="pb">
			<xsl:text>|</xsl:text>
			<span class="leftMargin" data-tei="@n">
				<xsl:value-of select="@n"/>
			</span>
		</span>
	</xsl:template>

	<!-- TEI line beginning, in preserveSpace environment -->
	<xsl:template match="TEI/text//p//lb" priority="+1">
		<xsl:if test="current() >> ancestor::p/lb[1]">
			<br/>
		</xsl:if>
	</xsl:template>

	<!-- TEI line beginning, inside of preformatted environment -->
	<xsl:template match="TEI/text//ab//lb" priority="+1">
		<xsl:if test="current() >> ancestor::ab/lb[1]">
			<br/>
		</xsl:if>
	</xsl:template>

<!-- General lb und pc break-->
	<xsl:template match="lb" priority="10">
		<br/>
	</xsl:template>
	
	<xsl:template match="pc[@type='br']">
		<xsl:value-of select="."/>
		<wbr/>
	</xsl:template>

	<!-- TEI term -->
	<xsl:template match="TEI/text//term[@target]">
		<span class="editorialMark rightMargin">
			<xsl:text>✻</xsl:text>
		</span>
			<xsl:apply-templates/>
			<xsl:apply-templates mode="note" select="id(substring(@target, 2))"/>
	</xsl:template>

	<!-- rs - Notes and Savestates-->
	<xsl:template match="rs[@ref]">
		<span class="term" data-tei="rs">
			<xsl:apply-templates/>
			<span class="note-popup">
				<xsl:apply-templates select="key('notes-by-id', substring-after(@ref, '#'))" mode="display-note-content"/>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template match="rs[@ref][key('notes-by-id', substring-after(@ref, '#'))/@type = 'savestate']" priority="2">
		<span class="term term-savestate" data-tei="rs">
			<xsl:apply-templates/>
			<span class="note-popup">
				<xsl:apply-templates select="key('notes-by-id', substring-after(@ref, '#'))" mode="display-note-content"/>
			</span>
		</span>
	</xsl:template>
	
	<!-- parse only in "note" mode -->
	<xsl:template match="TEI/text//note" mode="note">
		<span class="note" data-tei="note">
			<xsl:apply-templates/>
			<xsl:apply-templates select="@resp"/>
			<img src="{id(substring(@facs,2))/@url}"/>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//note/@resp">
		<xsl:text> </xsl:text>
		<i data-tei="@resp">
			<xsl:value-of select="."/>
		</i>
	</xsl:template>

	<xsl:template match="note" mode="display-note-content">
		<xsl:if test="@facs and id(substring(@facs,2))/@url">
			<img src="{id(substring(@facs,2))/@url}">
				<xsl:attribute name="class">
					<xsl:value-of select="@rend"/>
				</xsl:attribute>
				<xsl:attribute name="alt">
					<xsl:value-of select="@xml:id"/>
				</xsl:attribute>
			</img>
		</xsl:if>
		
		<xsl:for-each select="ref[@target]">
			<xsl:variable name="noteId" select="parent::note/@xml:id"/>
			
			<xsl:if test="@facs and id(substring(@facs,2))/@url">
				<img src="{id(substring(@facs,2))/@url}"/>
			</xsl:if>			
			<xsl:value-of select="."/>			
			<a href="{@target}" download="{$noteId}.vsf">
				Snapshot Vice 3.9
			</a>
		</xsl:for-each>		
		<xsl:apply-templates select="node()[not(self::ref)]"/>
	</xsl:template>

	<!-- WHITESPACE -->

	<!-- whitespace in newline -->
	<!-- do not render -->
	<xsl:template match="TEI/text//text()">
		<xsl:analyze-string regex="\n" select=".">
			<xsl:matching-substring/>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<xsl:template match="TEI/text//ab[@type='boxDrawing']">
		<span class="{@rend}" data-tei="ab">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//pb | TEI/text//cb" priority="1">
		
		<xsl:variable as="element()" name="type">
			<xsl:choose>
				<xsl:when test="name() = 'pb'">
					<foo symbol="" type="Seite"/>
				</xsl:when>
				<xsl:when test="name() = 'cb'">
					<foo symbol="" type="Spalte"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<span class="editorial fontReset {name(.)}" title="{$type/@type}nanfang">
			<xsl:if test="@type = 'skipped'">
				<xsl:text>… </xsl:text>
			</xsl:if>
			<xsl:if test="@break = 'no'">
				<xsl:text>-</xsl:text>
			</xsl:if>			
			<xsl:value-of select="$type/@symbol"/>
			<xsl:choose>
				<xsl:when test="@facs">
					<a href="{id(substring(@facs,2))/@url}">
						<xsl:apply-templates select="@n"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@n"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$type/@symbol"/>
			<xsl:if test="not(@break) or @break = 'yes'">
				<xsl:text></xsl:text>
			</xsl:if>
			<xsl:if test="@type = 'skipped'">
				<xsl:text> …</xsl:text>
			</xsl:if>
		</span>
		<xsl:variable name="cbPbImageUrl" select="id(substring(@facs,2))/@url"/>
		<xsl:if test="@facs and $cbPbImageUrl != ''">
			<img src="{$cbPbImageUrl}">
				<xsl:if test="@rend">
					<xsl:attribute name="class">
	 				<xsl:value-of select="@rend"/>
					</xsl:attribute>
				</xsl:if>
			</img>
		</xsl:if>
	</xsl:template>
	
	<!-- Zeilenumbruch mit Wortunterbrechung -->
	<!-- default -->
	<xsl:template match="TEI/text//lb[not(@break)]">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<!-- Zeilenumbrüche überall rausfiltern -->
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="\n">
			<xsl:matching-substring/>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

</xsl:stylesheet>