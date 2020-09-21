<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    exclude-result-prefixes="xsi xlink xs ali">
    
    <xsl:output encoding="UTF-8" method="xml"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="*|@*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Remove any rogue bold tags from paragraphs in captions as these are not required -->
    <xsl:template match="caption/p/bold">
        <xsl:apply-templates/>
    </xsl:template>
    
<!-- 
 Tweaks extyles XML as follows:
 
 converts DTD to schema
 expands xref spands into individual xrefs 
 
 ...and a lot more now...
-->
    <xsl:variable name="sbmj-code-list">
        <xsl:copy-of select="doc('resources/sbmjtopics.xml')"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:message>Tweaking extyles XML</xsl:message>
                <xsl:choose>
            <xsl:when test="article">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Do nothing-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Change Journal Title to 'BMJ' -->
    <xsl:template match="journal-title-group/journal-title">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>BMJ</xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <!-- Remove print ISSN -->
    <xsl:template match="journal-meta/issn[@pub-type='ppub']"/>
    
    <!-- Change ISSN to match the correct Journal Title -->
    <xsl:template match="journal-meta/issn[@pub-type='epub']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>1756-1833</xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <!-- Deal with collaborators tagging from eXtyles -->
    
    <xsl:template match="contrib-group[following-sibling::contrib-group[@content-type='collab-list']]">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:copy-of select="following-sibling::contrib-group[@content-type='collab-list']/aff"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="contrib-group[@content-type='collab-list']">
        <contrib-group content-type="collaborators">
            <contrib contrib-type="author non-byline">
                    <collab>
                        <xsl:value-of select="preceding-sibling::contrib-group//on-behalf-of/substring-after(text(),'on behalf of the ')"/>
                    </collab>
            </contrib>
            <xsl:for-each select="contrib//name">
                <contrib contrib-type="author non-byline">
                    <name>
                        <xsl:if test="surname">
                            <xsl:copy-of select="surname"/>
                        </xsl:if>
                        <xsl:if test="given-names">
                            <xsl:copy-of select="given-names"/>
                        </xsl:if>
                    </name>
                </contrib>
            </xsl:for-each>
        </contrib-group>
    </xsl:template>
    
    <!-- Tweak media block to ouput name of video with extenstion in xlink:href -->
    <xsl:template match="media[@mimetype]">
        <xsl:copy>
            <xsl:copy-of select="@id|@xlink:role|@content-type|@mimetype|@mime-subtype"/>
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="object-id/text()"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="@mime-subtype"/>
            </xsl:attribute>
            <xsl:attribute name="xlink:role">
                <xsl:text>external-host-filename</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
            <object-id pub-id-type="media-player-id">The BMJ Video Player</object-id>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xsl:template match="article">
        <xsl:element name="article">
            <xsl:apply-templates select="@*"/>
<!--            <xsl:attribute name="xsi:noNamespaceSchemaLocation" select="'http://dtd.nlm.nih.gov/publishing/2.3/xsd/journalpublishing.xsd'"/>-->
<!--            20150820 chnge to point to jats11d3, part of testing extyles 3311 build-->
            <xsl:attribute name="article-type" select="@article-type"/>
            <xsl:attribute name="dtd-version" select="@dtd-version"/>
            <xsl:variable name="schemalocation">
                <xsl:text>http://jats.nlm.nih.gov/publishing/</xsl:text>
                <xsl:value-of select="@dtd-version"/>
                <xsl:text>/xsd/JATS-journalpublishing1-mathml3.xsd</xsl:text>
            </xsl:variable>
            <xsl:attribute name="xsi:noNamespaceSchemaLocation" select="$schemalocation"/>
            <xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
            <xsl:namespace name="mml">http://www.w3.org/1998/Math/MathML</xsl:namespace>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="article-meta/issue[string-length(normalize-space(.))=0]">
<!--        suppress empty issue element-->
    </xsl:template>
    
    <xsl:template match="related-article[not(@related-article-type='corrected-article')]">
        <related-article xsl:exclude-result-prefixes="xs">
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="ext-link">
                    <xsl:attribute name="ext-link-type">
                        <xsl:value-of select="ext-link[1]/@ext-link-type"/>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="ext-link[1]/@xlink:href"/>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:type">
                        <xsl:text>simple</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </related-article>
    </xsl:template>
    
    
    <!-- ORCID ID tweaks as eXtyles does not create the right XML elements when 'HTTPS' is included as part of the URL -->
    
    <!-- Suppress any ext-link that contains an orcid id to prevent bad output from eXtyles when URL contains 'https' -->
    <xsl:template match="article-meta/contrib-group/contrib/ext-link[contains(.,'https://orcid')]"/>
    
    <!-- Replace instances where ext-link for orcid id is created with the correct contrib-id element -->
    <xsl:template match="contrib[ext-link[contains(.,'http://orcid')]]">
        <contrib>
            <contrib-id contrib-id-type="orcid">
                <xsl:value-of select="ext-link[contains(.,'http://orcid')]"/>
            </contrib-id>
            <xsl:apply-templates/>
        </contrib>
    </xsl:template>
    
    <!-- Add 'related-article' tagging for Addendum articles -->
    <xsl:template match="//ext-link[ancestor::body][@ext-link-type='doi'][ancestor::article[@article-type='addendum']]">
        <related-article 
            ext-link-type="{@ext-link-type}" 
            related-article-type="addended-article" 
            xlink:href="{@xlink:href}">
            <xsl:attribute name="id">
                <xsl:text>ra</xsl:text>
                <xsl:value-of select="./count(preceding::ext-link[ancestor::body][@ext-link-type='doi'][ancestor::article[@article-type='addendum']]) + 1"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </related-article>
    </xsl:template>
    
    <!-- Add 'related-article' tagging for Corrections articles -->
    <xsl:template match="//ext-link[ancestor::body][@ext-link-type='doi' or @ext-link-type='uri'][ancestor::article[@article-type='correction']]">
        <related-article ext-link-type="{@ext-link-type}" related-article-type="corrected-article" xlink:href="{@xlink:href}">
            <xsl:attribute name="id">
                <xsl:text>ra</xsl:text>
                <xsl:value-of select="./count(preceding::ext-link[ancestor::body][@ext-link-type='doi'][ancestor::article[@article-type='correction']]) + 1"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </related-article>
    </xsl:template>
    
    
    <!-- Replaces any instances of formatting (eg. bold or italic tags) being output in the XML comments from Extyles -->
    <xsl:template match="//comment()">
        <xsl:comment>
           <xsl:value-of select="replace(.,'&lt;.*?&gt;','')"/>
        </xsl:comment>
    </xsl:template>
    
    <!-- /////////////////////// -->
    <!-- CLINICAL TRIALS TAGGING -->
    <!-- /////////////////////// -->
    
    <xsl:template match="//processing-instruction()[local-name()[contains(.,'ISRCTN')]][2]">
        <ext-link xlink:href="{local-name()}">
            <xsl:attribute name="ext-link-type">
                <xsl:text>isrctn</xsl:text>
            </xsl:attribute>
            <!--<xsl:attribute name="specific-use">
                <xsl:text>results</xsl:text>
            </xsl:attribute>-->
            <xsl:value-of select="local-name()"/>
        </ext-link>
    </xsl:template>
    
    <xsl:template match="//processing-instruction()[local-name()[contains(.,'NCT')]][2]">
        <ext-link xlink:href="{local-name()}">
            <xsl:attribute name="ext-link-type">
                <xsl:text>clintrialgov</xsl:text>
            </xsl:attribute>
            <!--<xsl:attribute name="specific-use">
                <xsl:text>results</xsl:text>
            </xsl:attribute>-->
            <xsl:value-of select="local-name()"/>
        </ext-link>
    </xsl:template>
    
    
    <!--<xsl:template match="//sec/title[matches(.,'Trial registration')]">
        <title>
            <xsl:value-of select="."/>
        </title>
        <xsl:if test="following-sibling::p[contains(.,'ISRCTN')]">
            <p>
                <xsl:value-of select="following-sibling::p/text()/substring-before(.,' ISRCTN')"/>
                <ext-link xlink:href="{.}">
                    <xsl:attribute name="ext-link-type">
                        <xsl:text>isrctn</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="results-type">
                        <xsl:text>results</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </ext-link>
            </p>
        </xsl:if>
    </xsl:template>-->
    
    
<!--    <xsl:template name="results-type">
        <xsl:if test="./following-sibling::processing-instruction('RT') = 'results'">
            <xsl:attribute name="specific-use">
                <xsl:text>clinicaltrial results</xsl:text>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./following-sibling::processing-instruction('RT') = 'pre-results'">
            <xsl:attribute name="specific-use">
                <xsl:text>clinicaltrial pre-results</xsl:text>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./following-sibling::processing-instruction('RT') = 'post-results'">
            <xsl:attribute name="specific-use">
                <xsl:text>clinicaltrial post-results</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    
    <!-\- Create ext-link tag with supporting attributes for clinical trials-\->
    <xsl:template match="processing-instruction('ISRCTN')[2]">
        <ext-link xlink:href="{.}">
            <xsl:attribute name="ext-link-type">
                <xsl:text>isrctn</xsl:text>
            </xsl:attribute>
            <xsl:if test="./following-sibling::processing-instruction('RT')">
                <xsl:call-template name="results-type"/>
            </xsl:if>
            <xsl:value-of select="."/>
        </ext-link>
    </xsl:template>
    
    <xsl:template match="processing-instruction('NCT')[2]">
        <ext-link xlink:href="{.}">
            <xsl:attribute name="ext-link-type">
                <xsl:text>clintrialgov</xsl:text>
            </xsl:attribute>
            <xsl:if test="./following-sibling::processing-instruction('RT')">
                <xsl:call-template name="results-type"/>
            </xsl:if>
            <xsl:value-of select="."/>
        </ext-link>
    </xsl:template>-->
    <!-- /////////////////////// -->
    <!-- /////////////////////// -->
    
    
   
    <xsl:template match="article-meta[ancestor::article//processing-instruction()[local-name()[matches(.,'covid-19-pmc')]]]
        |article-meta[ancestor::article//following::processing-instruction('nih-funded')]
        |article-meta[ancestor::article//following::processing-instruction('free')]
        |article-meta[ancestor::article//processing-instruction('cccme')]
        |article-meta[ancestor::article//processing-instruction('fast-track')]">
        <xsl:copy>
            <xsl:apply-templates/>
            <custom-meta-group>
                <xsl:if test="ancestor::article//processing-instruction()[local-name()[matches(.,'covid-19-pmc')]]">
                    <custom-meta>
                        <meta-name>covid-19-pmc</meta-name>
                        <meta-value>true</meta-value>
                    </custom-meta>
                </xsl:if>
                <xsl:if test="ancestor::article//processing-instruction()[local-name()[matches(.,'nih-funded')]]">
                    <custom-meta>
                        <meta-name>nih-funded</meta-name>
                        <meta-value>true</meta-value>
                    </custom-meta>
                </xsl:if>
                <xsl:if test="ancestor::article//processing-instruction()[local-name()[matches(.,'free')]]">
                    <custom-meta>
                        <meta-name>access-type</meta-name>
                        <meta-value>free</meta-value>
                    </custom-meta>
                </xsl:if>
                <xsl:if test="ancestor::article//processing-instruction()[local-name()[matches(.,'fast-track')]]">
                    <custom-meta>
                        <meta-name>special-property</meta-name>
                        <meta-value>fast-track</meta-value>
                    </custom-meta>
                </xsl:if>
                <xsl:if test="ancestor::article//processing-instruction()[local-name()[matches(.,'cccme')]]">
                    <custom-meta>
                        <meta-name>special-property</meta-name>
                        <meta-value>cccme</meta-value>
                    </custom-meta>
                </xsl:if>
            </custom-meta-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="permissions[license[@license-type='open-access']]/copyright-statement">
        <xsl:if test="//license[@license-type='open-access']/license-p/ext-link/@xlink:href[contains(.,'/by-nc/')]">
            <copyright-statement>© Author(s) (or their employer(s)) 2019. Re-use permitted under CC
                BY-NC. No commercial re-use. See rights and permissions. Published by
                BMJ.</copyright-statement>
        </xsl:if>
        <xsl:if test="//license[@license-type='open-access']/license-p/ext-link/@xlink:href[contains(.,'/by/')]">
            <copyright-statement>© Author(s) (or their employer(s)) 2019. Re-use permitted under CC
                BY. No commercial re-use. See rights and permissions. Published by
                BMJ.</copyright-statement>
        </xsl:if>
    </xsl:template>
    
    
    <!-- Check for license and add ALI license tagging -->
    <xsl:template match="license[@license-type='open-access']">
        <xsl:choose>
            <xsl:when test="ali:license_ref">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <ali:license_ref>
                        <xsl:choose>
                            <xsl:when test="license-p/ext-link/@xlink:href[contains(.,'3.0')]">
                                <xsl:analyze-string select="license-p/ext-link/@xlink:href" regex="3.0">
                                    <xsl:matching-substring>
                                        <xsl:text>4.0</xsl:text>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ali:license_ref>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- This needs a check to make sure this is NOT OA too! -->
    <xsl:template match="permissions[//processing-instruction('covid-license') and not(//license[@license-type='open-access'])]">
        
        <permissions>
            <copyright-statement>Published by the BMJ Publishing Group Limited. For permission to use (where not already granted under a licence) please go to <ext-link ext-link-type="uri" xlink:href="http://group.bmj.com/group/rights-licensing/permissions">http://group.bmj.com/group/rights-licensing/permissions</ext-link>
            </copyright-statement>
            <copyright-year>
                <xsl:value-of select="//article-meta/pub-date/year/text()"/>
            </copyright-year>
            <ali:free_to_read xmlns:ali="http://www.niso.org/schemas/ali/1.0/" start_date="2020-04-01" end_date="2021-04-01"/>
            <license license-type="covid-19-tdm">
                <license-p>This article is made freely available for use in accordance with BMJ's website terms and conditions for the duration of the covid-19 pandemic or until otherwise determined by BMJ.  You may use, download and print the article for any lawful, non-commercial purpose (including text and data mining) provided that all copyright notices and trade marks are retained.</license-p>
                <ali:license_ref specific-use="covid-19-tdm" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">https://bmj.com/coronavirus/usage</ali:license_ref>
            </license>
        </permissions>
        
    </xsl:template>
    
    <!-- Add IGO license if processing instruction exists for this -->
    <xsl:template match="permissions[following::processing-instruction('igo-nc')]">
        
        <xsl:element name="permissions">
            
            <!--  -->
            <xsl:apply-templates select="*[not(self::license)]"/>
            
            <!-- Add if other Open Access license statement is already present -->
            <xsl:if test="license">
                <xsl:element name="license">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="license-type">
                        <xsl:text>open-access</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:href">
                        <xsl:text>https://creativecommons.org/licenses/by-nc/3.0/igo/</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="license-p">
                        <xsl:text>This is an Open Access article distributed under the terms of the Creative Commons Attribution IGO License (https://creativecommons.org/licenses/by-nc/3.0/igo/), which permits use, distribution, and reproduction for non-commercial purposes in any medium, provided the original work is properly cited.</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <!-- Add if no Open Access license statement is present -->
            <xsl:if test="not(license)">
                <xsl:element name="license">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="license-type">
                        <xsl:text>open-access</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:href">
                        <xsl:text>https://creativecommons.org/licenses/by-nc/3.0/igo/</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="license-p">
                        <xsl:text>This is an Open Access article distributed under the terms of the Creative Commons Attribution IGO License (https://creativecommons.org/licenses/by-nc/3.0/igo/), which permits use, distribution, and reproduction for non-commercial purposes in any medium, provided the original work is properly cited.</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
        
    </xsl:template>
    
    <!-- Add IGO license if processing instruction exists for this -->
    <xsl:template match="permissions[following::processing-instruction('igo-by')]">
        
        <xsl:element name="permissions">
            
            <xsl:apply-templates select="*[not(self::license)]"/>
            
            <!-- Add if other Open Access license statement is already present -->
            <xsl:if test="license">
                
                <xsl:element name="license">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="license-type">
                        <xsl:text>open-access</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:href">
                        <xsl:text>https://creativecommons.org/licenses/by/3.0/igo/</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="license-p">
                        <xsl:text>This is an Open Access article distributed under the terms of the Creative Commons Attribution IGO License (https://creativecommons.org/licenses/by/3.0/igo/), which permits use, distribution, and reproduction in any medium, provided the original work is properly cited.</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <!-- Add if no Open Access license statement is present -->
            <xsl:if test="not(license)">
                
                <xsl:element name="license">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="license-type">
                        <xsl:text>open-access</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:href">
                        <xsl:text>https://creativecommons.org/licenses/by/3.0/igo/</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="license-p">
                        <xsl:text>This is an Open Access article distributed under the terms of the Creative Commons Attribution IGO License (https://creativecommons.org/licenses/by/3.0/igo/), which permits use, distribution, and reproduction in any medium, provided the original work is properly cited.</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
        
    </xsl:template>
    
        <!-- Add IGO ND license if processing instruction exists for this -->
    <xsl:template match="permissions[following::processing-instruction('igo-nd')]">
        
        <xsl:element name="permissions">
            
            <xsl:apply-templates select="*[not(self::license)]"/>
            
            <!-- Add if other Open Access license statement is already present -->
            <xsl:if test="license">
                
                <xsl:element name="license">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="license-type">
                        <xsl:text>open-access</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:href">
                        <xsl:text>https://creativecommons.org/licenses/by-nc-nd/3.0/igo/</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="license-p">
                        <xsl:text>This is an Open Access article distributed under the terms of the Creative Commons Attribution Non Commercial No Derivs IGO License (CC BY-NC-ND 3.0 IGO), which permits distribution and reproduction for non-commercial purposes in any medium, provided the original work is properly cited. If you remix, transform, or build upon the material, you may not distribute the modified material. See: https://creativecommons.org/licenses/by-nc-nd/3.0/igo/ 
In any reproduction of this article there should not be any suggestion that PAHO or this article endorse any specific organisation or products.</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <!-- Add if no Open Access license statement is present -->
            <xsl:if test="not(license)">
                
                <xsl:element name="license">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="license-type">
                        <xsl:text>open-access</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xlink:href">
                        <xsl:text>https://creativecommons.org/licenses/by-nc-nd/3.0/igo/</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="license-p">
                        <xsl:text>This is an Open Access article distributed under the terms of the Creative Commons Attribution Non Commercial No Derivs IGO License (CC BY-NC-ND 3.0 IGO), which permits distribution and reproduction for non-commercial purposes in any medium, provided the original work is properly cited. If you remix, transform, or build upon the material, you may not distribute the modified material. See: https://creativecommons.org/licenses/by-nc-nd/3.0/igo/ 
In any reproduction of this article there should not be any suggestion that PAHO or this article endorse any specific organisation or products</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
        
    </xsl:template>
    
    <!-- Replace the test '3.0' text in old open access statements main text with '4.0' -->
    <xsl:template match="license/license-p//text()">
        <xsl:choose>
            <xsl:when test=".[contains(.,'3.0')]">
                <xsl:analyze-string select="." regex="3.0">
                <xsl:matching-substring>
                    <xsl:text>4.0</xsl:text>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:value-of select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Replace '3.0' in xlink:href for old open access statements with '4.0' -->
    <xsl:template match="license/license-p/ext-link/@xlink:href">
        <xsl:attribute name="xlink:href">
            <xsl:choose>
            <xsl:when test=".[contains(.,'3.0')]">
                <xsl:analyze-string select="." regex="3.0">
                <xsl:matching-substring>
                    <xsl:text>4.0</xsl:text>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:value-of select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="pub-id[ancestor::mixed-citation][@pub-id-type='doi']">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="text()[contains(.,'doi:')]">
                    <xsl:value-of select="text()/substring-after(.,'doi:')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="pub-id[ancestor::mixed-citation][@pub-id-type='pmid'][preceding-sibling::pub-id[@pub-id-type='doi']]">
        <xsl:text>&#x00A0;</xsl:text>
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="text()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Chris S added - 05/11/2015. Add colspan & rowspan to th or td without colspan or rowspan -->
    <xsl:template match="th|td">
               <xsl:element name="{local-name()}">
                   <xsl:copy-of select="@*"/>
                   <xsl:choose>
                       <xsl:when test="string-length(normalize-space(@colspan))!=0 and not(@rowspan)">
                           <xsl:attribute name="rowspan">
                               <xsl:text>1</xsl:text>
                           </xsl:attribute>
                           <xsl:apply-templates/>
                       </xsl:when>
                       <xsl:when test="string-length(normalize-space(@rowspan))!=0 and not(@colspan)">
                           <xsl:attribute name="colspan">
                               <xsl:text>1</xsl:text>
                           </xsl:attribute>
                           <xsl:apply-templates/>
                       </xsl:when>
                       <xsl:when test="string-length(normalize-space(@colspan))!=0 and string-length(normalize-space(@rowspan))!=0">
                           <xsl:apply-templates/>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:attribute name="colspan">
                               <xsl:text>1</xsl:text>
                           </xsl:attribute>
                           <xsl:attribute name="rowspan">
                               <xsl:text>1</xsl:text>
                           </xsl:attribute>
                           <xsl:apply-templates/>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:element>
    </xsl:template>
    
    <xsl:template match="subj-group/subject">
        <xsl:choose>
        <xsl:when test="text()[matches(.,'Research Methods and Reporting')]">
        <xsl:element name="subject">
                <xsl:value-of select="./replace('Research Methods and Reporting', 'and' ,'&amp;')"/>
        </xsl:element>
        </xsl:when>
        <xsl:otherwise>
        <xsl:element name="subject">
            <xsl:apply-templates/>
        </xsl:element>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="subj-group[@subj-group-type[not(matches(.,'heading'))]]">
        <xsl:variable name="journal" select="ancestor::front/journal-meta/journal-id[@journal-id-type='nlm-ta'][1]/text()"/>
        <xsl:variable name="section" select="ancestor::article-meta/article-categories/subj-group[@subj-group-type='heading'][1]/subject/text()"/>
        <xsl:call-template name="add-topic-codes">
            <xsl:with-param name="journal" select="$journal"/>
            <xsl:with-param name="section" select="$section"/>
            <xsl:with-param name="subjects">
                <xsl:copy-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
        <!--<xsl:choose>
            <xsl:when test="matches(normalize-space(ancestor::front/journal-meta/journal-id[@journal-id-type='nlm-ta'][1]),'^bmj$','i') 
                and matches(normalize-space(ancestor::article-categories/subj-group[@subj-group-type='heading']/subject),'^careers$','i')">
                <xsl:attribute name="subj-group-type">topics</xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(normalize-space(ancestor::front/journal-meta/journal-id[@journal-id-type='nlm-ta'][1]),'^student bmj$','i')">
                <xsl:attribute name="subj-group-type">topics</xsl:attribute>
            </xsl:when>
        </xsl:choose>-->
        
        <!--        suppress empty issue element-->
    </xsl:template>
    
    <xsl:template match="//fig[@fig-type='video']/graphic">
        <xsl:copy-of select="."/>
        <xsl:element name="media">
            <xsl:attribute name="xlink-href">
                <xsl:value-of select="./@xlink:href"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="article//text()[not(ancestor::td)][string-length(.)=1][matches(.,'-')][preceding-sibling::xref[@ref-type='bibr'][1][following-sibling::xref[@ref-type='bibr'][1]]]">
        <xsl:variable name="start-no" select="xs:integer(replace(preceding-sibling::xref[@ref-type='bibr'][1]/@rid,'^\D+(\d+)','$1','i'))+1"/>
        <xsl:variable name="end-no" select="xs:integer(replace(following-sibling::xref[1][@ref-type='bibr']/@rid,'^\D+(\d+)','$1','i'))-1"/>
       <xsl:choose>
            <xsl:when test="$start-no=$end-no">
                <xsl:element name="xref">
                    <xsl:attribute name="ref-type">bibr</xsl:attribute>
                    <xsl:attribute name="rid"><xsl:value-of select="concat('ref',string($start-no))"/>
                    </xsl:attribute>
                    <xsl:value-of select="string($start-no)"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="for $i in $start-no to $end-no return $i">
                    <xsl:element name="xref">
                        <xsl:attribute name="ref-type">bibr</xsl:attribute>
                        <xsl:attribute name="rid"><xsl:value-of select="concat('ref',string(.))"/></xsl:attribute>
                        <xsl:value-of select="string(.)"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="add-topic-codes">
       <xsl:param name="journal"/>
        <xsl:param name="section"/>
        <xsl:param name="subjects"/>
        <xsl:message>JOURNAL = <xsl:copy-of select="$journal"/></xsl:message>
        <xsl:message>SECTION = <xsl:copy-of select="$section"/></xsl:message>
        
        <xsl:message>RECIEVED SUBJECTS  <xsl:copy-of select="$subjects"/></xsl:message>
        <xsl:variable name="generic-topic-list">
            <xsl:for-each select=".//subject">
                <!--                              univadis codes have decimal points in them-->
                <xsl:analyze-string select="." regex="(top|\d+\.\d+(\.\d+)?)+">
                    <xsl:matching-substring>
                        <xsl:message>
                            <xsl:text>UV code found </xsl:text>
                            <xsl:copy-of select="regex-group(1)"/>
                        </xsl:message>
                        <xsl:element name="subject">
                            <xsl:attribute name="type" select="'univadis'"/>
                            <xsl:copy-of select="regex-group(1)"/>
                        </xsl:element>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:message>LOOKING AT <xsl:copy-of select="."/></xsl:message>
                        <xsl:analyze-string select="." regex="(\d+)">
                            <xsl:matching-substring>
                                <xsl:choose>
                                    <xsl:when test="matches(normalize-space($journal),'^student bmj$','i')">
                                        <xsl:message>Student code found <xsl:copy-of select="regex-group(1)"/></xsl:message>
                                        <xsl:element name="subject">
                                            <xsl:attribute name="type" select="'student'"/>
                                            <xsl:copy-of select="regex-group(1)"/>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:when test="matches(normalize-space($journal),'^bmj$','i') 
                                        and matches(normalize-space($section),'^careers$','i')">
                                        <xsl:message>BMJ Careers code found <xsl:copy-of select="regex-group(1)"/></xsl:message>
                                        <xsl:element name="subject">
                                            <xsl:attribute name="type" select="'bmj-careers'"/>
                                            <xsl:copy-of select="regex-group(1)"/>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>HighWire code found <xsl:copy-of select="regex-group(1)"/></xsl:message>
                                        <xsl:element name="subject">
                                            <xsl:attribute name="type" select="'highwire'"/>
                                            <xsl:copy-of select="regex-group(1)"/>
                                        </xsl:element>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring/>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:if test="count($generic-topic-list/subject[@type='univadis']) !=0">
            <xsl:message>I have UNIVADIS <xsl:value-of select="count($generic-topic-list/subject[@type='univadis'])"/></xsl:message>
            <xsl:call-template name="add-univadis-codes">
                <xsl:with-param name="codes">
                    <xsl:copy-of select="$generic-topic-list/subject[@type='univadis']"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="count($generic-topic-list/subject[@type='student']) !=0">
            <xsl:message>I have STUDENT <xsl:value-of select="count($generic-topic-list/subject[@type='student'])"/></xsl:message>
            <xsl:call-template name="add-student-codes">
                <xsl:with-param name="codes">
                    <xsl:copy-of select="$generic-topic-list/subject[@type='student']"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="count($generic-topic-list/subject[@type='bmj-careers']) !=0">
            <xsl:message>I have BMJ CAREERS <xsl:value-of select="count($generic-topic-list/subject[@type='bmj-careers'])"/></xsl:message>
            <xsl:call-template name="add-bmj-careers-codes">
                <xsl:with-param name="codes">
                    <xsl:copy-of select="$generic-topic-list/subject[@type='bmj-careers']"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="count($generic-topic-list/subject[@type='highwire']) !=0">
            <xsl:message>I have HIGHWIRE <xsl:value-of select="count($generic-topic-list/subject[@type='highwire'])"/></xsl:message>
            <xsl:call-template name="add-highwire-codes">
                <xsl:with-param name="codes">
                    <xsl:copy-of select="$generic-topic-list/subject[@type='highwire']"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="add-topic-codes-old">
        <xsl:param name="subjects"/>
        <xsl:message>RECIEVED SUBJECTS  <xsl:copy-of select="$subjects"/></xsl:message>
        <xsl:choose>
<!--            student -->
            <xsl:when
                test="matches(normalize-space(ancestor::front/journal-meta/journal-id[@journal-id-type='nlm-ta'][1]),'^student bmj$','i')">
                <xsl:variable name="code-list">
                    <xsl:copy-of select="doc('resources/sbmjtopics.xml')"/>
                </xsl:variable>
                <xsl:message>PROCESSING STUDENT TOPICS</xsl:message>
                <!--<xsl:message>CODE LIST IS <xsl:value-of select="$code-list"/></xsl:message>-->
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">
                        <xsl:value-of select="'topics'"/>
                    </xsl:attribute>
                    <xsl:for-each select="$subjects//subject">
                        <xsl:variable name="this-code" select="normalize-space(text())"/>
                        <xsl:message>GOT THIS CODE <xsl:value-of select="$this-code"/></xsl:message>
                        <xsl:copy-of
                            select="$code-list//subject[@content-type=$this-code]"/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
<!--            bmj careers -->
            <xsl:when
                test="matches(normalize-space(ancestor::front/journal-meta/journal-id[@journal-id-type='nlm-ta'][1]),'^bmj$','i') 
                and matches(normalize-space(ancestor::article-categories/subj-group[@subj-group-type='heading']/subject),'^careers$','i')">
                <xsl:message>PROCESSING BMJ CAREERS TOPICS</xsl:message>
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">
                        <xsl:value-of select="'topics'"/>
                    </xsl:attribute>
                    <xsl:copy-of select="$subjects//subject"/>
                </xsl:element>
            </xsl:when>
<!--     univadis            -->
            <xsl:otherwise>
                <xsl:message>PROCESSING OTHER TOPICS</xsl:message>
                <!--                              univadis codes have decimal points in them-->
                <xsl:variable name="topic-codes">
                    <xsl:for-each select="$subjects//subject">
                        <xsl:analyze-string select="text()" regex="(top|\d+\.\d+(\.\d+)?)+">
                            <xsl:matching-substring>
                                <xsl:message>
                                    <xsl:text>UV code found </xsl:text>
                                    <xsl:copy-of select="regex-group(1)"/>
                                </xsl:message>
                                <xsl:element name="subject">
                                    <xsl:attribute name="type" select="'univadis'"/>
                                    <xsl:copy-of select="regex-group(1)"/>
                                </xsl:element>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="(\d+)">
                                    <xsl:matching-substring>
                                        <!--                                                  <xsl:message>
                                            <xsl:text>HW code found</xsl:text>
                                            <xsl:copy-of select="regex-group(1)"/>
                                            </xsl:message>
                                        -->                                     
                                        <xsl:element name="subject">
                                            <xsl:attribute name="type" select="'highwire'"/>
                                            <xsl:copy-of select="regex-group(1)"/>
                                        </xsl:element>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring/>
                                </xsl:analyze-string>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                        
                    </xsl:for-each>
                    
                    
                </xsl:variable>
                
                <xsl:message>COPY OF TOPIC CODES VARIABLE IS <xsl:copy-of select="$topic-codes"></xsl:copy-of></xsl:message>
                <xsl:if test="count($topic-codes/subject[@type='univadis']) !=0">
                    <xsl:message>I have UNIVADIS <xsl:value-of select="count($topic-codes/subject[@type='univadis'])"/></xsl:message>
                    <xsl:call-template name="add-univadis-codes">
                        <xsl:with-param name="codes">
                            <xsl:copy-of select="$topic-codes/subject[@type='univadis']"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="count($topic-codes/subject[@type='highwire']) !=0">
                    <xsl:message>I have HIGHWIRE <xsl:value-of select="count($topic-codes/subject[@type='highwire'])"/></xsl:message>
                    <xsl:call-template name="add-highwire-codes">
                        <xsl:with-param name="codes">
                            <xsl:copy-of select="$topic-codes/subject[@type='highwire']"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
                
                
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    <xsl:template name="add-student-codes">
        <xsl:param name="codes"/>
        <xsl:variable name="sbmj-code-list">
            <xsl:copy-of select="doc('resources/sbmjtopics.xml')"/>
        </xsl:variable>
        <xsl:element name="subj-group">
            <xsl:attribute name="subj-group-type">
                <xsl:value-of select="'topics'"/>
            </xsl:attribute>
            <xsl:for-each select="$codes/subject">
                <xsl:variable name="this-code" select="./text()"/>
                    <xsl:copy-of
                        select="$sbmj-code-list//subject[@content-type=$this-code]"/>
            </xsl:for-each>
    </xsl:element>
    </xsl:template>
    
    <xsl:template name="add-highwire-codes">
        <xsl:param name="codes"/>
        <xsl:element name="subj-group">
            <xsl:attribute name="subj-group-type">
                <xsl:value-of select="'hwp-journal-coll'"/>
            </xsl:attribute>
            <xsl:for-each select="$codes/subject">
                <xsl:element name="subject">
                    <xsl:copy-of select="./text()"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="add-bmj-careers-codes">
        <xsl:param name="codes"/>
        <xsl:element name="subj-group">
            <xsl:attribute name="subj-group-type">
                <xsl:value-of select="'topics'"/>
            </xsl:attribute>
            <xsl:for-each select="$codes/subject">
                <xsl:element name="subject">
                    <xsl:copy-of select="./text()"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="add-univadis-codes">
        <!--          univadis code families are:
            top_article:top
            customer-type:102.*
            media-type: 107.*
            specialties: 201.*
            conditions 202.*.*
            news-type 210.*
        -->
        
        <xsl:param name="codes"/>
        <xsl:variable name="uv-top-article">
            <xsl:copy-of select="$codes/subject[matches(text(),'^\s*top*')]"/>
        </xsl:variable>
        <xsl:variable name="uv-customer-type">
            <xsl:copy-of select="$codes/subject[matches(text(),'^\s*102\.*')]"/>
        </xsl:variable>
        <xsl:variable name="uv-media-type">
            <xsl:copy-of select="$codes/subject[matches(text(),'^\s*107\.*')]"/>
        </xsl:variable>
        <xsl:variable name="uv-specialties">
            <xsl:copy-of select="$codes/subject[matches(text(),'^\s*201\.*')]"/>
        </xsl:variable>
        <xsl:variable name="uv-conditions">
            <xsl:copy-of select="$codes/subject[matches(text(),'^\s*202\.*')]"/>
        </xsl:variable>
        <xsl:variable name="uv-type-categorization">
            <xsl:copy-of select="$codes/subject[matches(text(),'^\s*210\.*')]"/>
        </xsl:variable>
        
        <!--          uv-top-article-->
        <xsl:choose>
            <xsl:when test="count($uv-top-article/subject) !=0">
                <xsl:message>I have uv-top-article <xsl:value-of select="count($uv-top-article/subject)"/></xsl:message>
                <xsl:message> <xsl:copy-of select="$uv-top-article"/></xsl:message>
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">
                        <xsl:value-of select="'univadis-top-article'"/>
                    </xsl:attribute>
                    <xsl:element name="subject">
                        <xsl:text>1</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">
                        <xsl:value-of select="'univadis-top-article'"/>
                    </xsl:attribute>
                    <xsl:element name="subject">
                        <xsl:text>0</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        
        <!--          uv-customer-type-->
        <xsl:if test="count($uv-customer-type/subject) !=0">
            <xsl:message>I have uv-customer-type <xsl:value-of select="count($uv-customer-type/subject)"/></xsl:message>
            <xsl:message><xsl:copy-of select="$uv-customer-type"/></xsl:message>
            <xsl:element name="subj-group">
                <xsl:attribute name="subj-group-type">
                    <xsl:value-of select="'univadis-customer-type'"/>
                </xsl:attribute>
                <xsl:call-template name="make-univadis-subject">
                    <xsl:with-param name="this-code-list">
                        <xsl:copy-of select="$uv-customer-type"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
        
        <!--          uv-media-type-->
        <xsl:if test="count($uv-media-type/subject) !=0">
            <xsl:message>I have uv-media-type <xsl:value-of select="count(uv-media-type/subject)"/></xsl:message>
            <xsl:message><xsl:copy-of select="$uv-media-type"/></xsl:message>
            <xsl:element name="subj-group">
                <xsl:attribute name="subj-group-type">
                    <xsl:value-of select="'univadis-media-type'"/>
                </xsl:attribute>
                <xsl:call-template name="make-univadis-subject">
                    <xsl:with-param name="this-code-list">
                        <xsl:copy-of select="$uv-media-type"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
        
        <!--          uv-specialties-->         
        <xsl:if test="count($uv-specialties/subject) !=0">
            <xsl:message>I have uv-specialties <xsl:value-of select="count($uv-specialties/subject)"/></xsl:message>
            <xsl:message><xsl:copy-of select="$uv-specialties"/></xsl:message>
            <xsl:element name="subj-group">
                <xsl:attribute name="subj-group-type">
                    <xsl:value-of select="'univadis-specialties'"/>
                </xsl:attribute>
                <xsl:call-template name="make-univadis-subject">
                    <xsl:with-param name="this-code-list">
                        <xsl:copy-of select="$uv-specialties"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
            
        </xsl:if>
        
        <!--          uv-conditions-->
        <xsl:if test="count($uv-conditions/subject) !=0">
            <xsl:message>I have uv-conditions <xsl:value-of select="count($uv-conditions/subject)"/></xsl:message>
            <xsl:message><xsl:copy-of select="$uv-conditions"/></xsl:message>
            <xsl:element name="subj-group">
                <xsl:attribute name="subj-group-type">
                    <xsl:value-of select="'univadis-conditions'"/>
                </xsl:attribute>
                <xsl:call-template name="make-univadis-subject">
                    <xsl:with-param name="this-code-list">
                        <xsl:copy-of select="$uv-conditions"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
            
        </xsl:if>
        
        <!--          uv-type-categorization-->
        <xsl:if test="count($uv-type-categorization/subject) !=0">
            <xsl:message>I have uv-type-categorization <xsl:value-of select="count(uv-type-categorization/subject)"/></xsl:message>
            <xsl:message><xsl:copy-of select="$uv-type-categorization"/></xsl:message>
            <xsl:element name="subj-group">
                <xsl:attribute name="subj-group-type">
                    <xsl:value-of select="'univadis-type-categorization'"/>
                </xsl:attribute>
                <xsl:call-template name="make-univadis-subject">
                    <xsl:with-param name="this-code-list">
                        <xsl:copy-of select="$uv-type-categorization"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="make-univadis-subject">
        <xsl:param name="this-code-list"/>
        <xsl:for-each select="$this-code-list/subject">
            <xsl:element name="subject">
                <xsl:value-of select="normalize-space(text())"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>

