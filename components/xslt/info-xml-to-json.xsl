<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="3.0">
  
  <xsl:output encoding="UTF-8" method="text"/>
  
  <xsl:template match="/">
    <xsl:text>{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:variable name="pre-key">
    <xsl:text>:</xsl:text>
    <xsl:text>"</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="post-key">
    <xsl:text>"</xsl:text>
    <xsl:text>,</xsl:text>
  </xsl:variable>
  
  <xsl:template match="*[parent::*]">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>

  <xsl:template match="*[@name='pub-id']">
    <xsl:text>"</xsl:text>
    <xsl:text>pubID</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>

  <xsl:template match="*[@name='first-auth']">
    <xsl:text>"</xsl:text>
    <xsl:text>firstAuthor</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>

  <xsl:template match="*[@name='data-supps']">
    <xsl:text>"</xsl:text>
    <xsl:text>dataSupplements</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>

  <xsl:template match="*[@name='pub.hwx']">
    <xsl:text>"</xsl:text>
    <xsl:text>pubHWX</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>

  <xsl:template match="*[@name='embargo.date']">
    <xsl:text>"</xsl:text>
    <xsl:text>embargoDate</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>

  <xsl:template match="*[@name='embargo.time']">
    <xsl:text>"</xsl:text>
    <xsl:text>embargoTime</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>
  
  <xsl:template match="*[@name='status']">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="@report/local-name()"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="@report"/>
    <xsl:value-of select="$post-key"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$post-key"/>
  </xsl:template>

  <xsl:template match="*[@link]">
    <xsl:text>"</xsl:text>
    <xsl:text>articleLink</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="@link"/>
    <xsl:value-of select="$post-key"/>
    <xsl:text>"</xsl:text>
    <xsl:text>hwBatch</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$pre-key"/>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[parent::*][not(following-sibling::*)][not(@link)]">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>"</xsl:text>
    <xsl:text>:</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  
</xsl:stylesheet>