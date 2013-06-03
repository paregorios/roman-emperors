<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 7, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> paregorios</xd:p>
            <xd:p>String variables for TTL output</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:variable name="n">
        <xsl:text>
</xsl:text>
    </xsl:variable>
    <xsl:variable name="t">
        <xsl:text>  </xsl:text>
    </xsl:variable>
    <xsl:variable name="s">
        <xsl:text>;</xsl:text>
    </xsl:variable>   
    <xsl:variable name="p">
        <xsl:text>.</xsl:text>
    </xsl:variable>
    <xsl:variable name="c">
        <xsl:text>,</xsl:text>
    </xsl:variable>
    <xsl:variable name="nt"><xsl:value-of select="$n"/><xsl:value-of select="$t"/></xsl:variable>
    <xsl:variable name="snt"><xsl:text> </xsl:text><xsl:value-of select="$s"/><xsl:value-of select="$nt"/></xsl:variable>
    <xsl:variable name="sntt"><xsl:text> </xsl:text><xsl:value-of select="$s"/><xsl:value-of select="$nt"/><xsl:value-of select="$t"/></xsl:variable>
    <xsl:variable name="cntt"><xsl:text> </xsl:text><xsl:value-of select="$c"/><xsl:value-of select="$nt"/><xsl:value-of select="$t"/></xsl:variable>
    <xsl:variable name="pn"><xsl:text> </xsl:text><xsl:value-of select="$p"/><xsl:value-of select="$n"/></xsl:variable>
</xsl:stylesheet>