<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bio="http://vocab.org/bio/0.1/" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:owl="http://www.w3.org/2002/07/owl#" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:relationship="http://purl.org/vocab/relationship/"
    xmlns:void="http://rdfs.org/ns/void#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    exclude-result-prefixes="xs bio dc foaf owl rdf rdfs relationship void dcterms"
    version="2.0">
    
    <xsl:param name="where">pkg</xsl:param>
    <xsl:param name="docbase">http://www.paregorios.org/resources/roman-emperors/</xsl:param>
    <xsl:param name="cssbase"><xsl:value-of select="$docbase"/>css/</xsl:param>
    <xsl:output method="xhtml" indent="yes" name="html" omit-xml-declaration="no"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="rdf:RDF">
        <!-- open the void file and get overview info -->
        <xsl:variable name="vrdf" select="document('../void.rdf')//rdf:RDF"/>
        <xsl:variable name="vdset" select="$vrdf/descendant::void:Dataset[@rdf:about='#RomanEmperors']"/>
        <xsl:variable name="vtitle" select="normalize-space($vdset/dcterms:title)"/>
        <xsl:variable name="vdesc" select="normalize-space($vdset/dcterms:description)"/>
        <xsl:variable name="vpage"  select="normalize-space($vdset/foaf:homepage/@rdf:resource)"/>
        <xsl:result-document href="{$where}/index.html" format="html">
            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
            <html>
                <head>
                    <title><xsl:value-of select="$vtitle"/></title>
                    <xsl:call-template name="cssandscripts"/>
                </head>
                <body>
                    <h1><xsl:value-of select="$vtitle"/></h1>
                    <p>This dataset provides: <xsl:value-of select="$vdesc"/></p>
                    <p>Primary URI for this dataset (permalink): <a href="{$vpage}"><xsl:value-of select="$vpage"/></a></p>
                    <p class="navaid"><a href="#content">jump to content</a></p>
                    <div id="datasetinfo">
                        <h2>Information about this dataset</h2>
                        <p class="navaid"><a href="{$docbase}void.rdf">void file</a></p>
                        <xsl:apply-templates select="$vdset/*"/>
                    </div>
                    <div id="content">
                        <h2>Content of the dataset</h2>
                        <ul>
                            <xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://xmlns.com/foaf/0.1/Person']">
                                <xsl:sort select="foaf:name[1]"/>
                                <xsl:sort select="foaf:name[2]"/>
                                <xsl:with-param name="vtitle" select="$vtitle"/>
                                <xsl:with-param name="vpage" select="$vpage"/>
                            </xsl:apply-templates>
                        </ul>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="rdf:Description[rdf:type/@rdf:resource='http://xmlns.com/foaf/0.1/Person']">
        <xsl:param name="vtitle"/>
        <xsl:param name="vpage"/>
        
        <xsl:message>trying to handle <xsl:value-of select="@rdf:about"/></xsl:message>
        
        <!-- determine the master filename for this person document -->
        <xsl:variable name="filename">
            <xsl:text>about-</xsl:text>
            <xsl:call-template name="cleanfilname">
                <xsl:with-param name="raw" select="@rdf:about"/>
            </xsl:call-template>            
        </xsl:variable>
        <xsl:message>    filename: <xsl:value-of select="$filename"/></xsl:message>
        
        <!-- create a link to this person document in the index.html page -->
        <xsl:message>    writing link in index.html</xsl:message>
        <li>
            <a href="{$filename}"><xsl:value-of select="foaf:name[1]"/><xsl:text></xsl:text>
                <xsl:for-each select="foaf:name[preceding-sibling::foaf:name]">
                    <xsl:if test="count(preceding-sibling::foaf:name) =1">
                        <xsl:text> (</xsl:text>
                    </xsl:if>
                    <xsl:text></xsl:text><xsl:value-of select="."/><xsl:text></xsl:text>
                    <xsl:if test="following-sibling::foaf:name">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="not(following-sibling::foaf:name)">
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </a>
        </li>
        
        <!-- create the target html page for this person doc -->
        <xsl:variable name="htmlfilename">
            <xsl:value-of select="$where"/>/<xsl:value-of select="$filename"/><xsl:text>/index.html</xsl:text>
        </xsl:variable>
        <xsl:call-template name="htmlpersondoc">
            <xsl:with-param name="filename" select="$htmlfilename"/>
            <xsl:with-param name="rawname" select="$filename"/>
            <xsl:with-param name="vpage" select="$vpage"/>
            <xsl:with-param name="vtitle" select="$vtitle"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="foaf:isPrimaryTopicOf" mode="topic">
        <xsl:variable name="uri" select="@rdf:resource"/>
        <li><a href="{$uri}"><xsl:value-of select="$uri"/></a>
            
                <xsl:for-each select="//rdf:Description[@rdf:about=$uri and rdf:type]">
                    <xsl:if test="not(preceding-sibling::rdf:Description[@rdf:about=$uri and rdf:type])">
                        <xsl:text> (</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="lower-case(tokenize(rdf:type/@rdf:resource, '/')[last()])"/>
                    <xsl:if test="following-sibling::rdf:Description[@rdf:about=$uri and rdf:type]">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="not(following-sibling::rdf:Description[@rdf:about=$uri and rdf:type])">
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:for-each>
        </li>
    </xsl:template>
    
    <xsl:template match="foaf:name">
        <p>Name: <span class="name"><xsl:value-of select="normalize-space(.)"/></span></p>
    </xsl:template>
    
    <xsl:template match="foaf:based_near">
        <p>Based near: 
            <xsl:choose>
                <xsl:when test="starts-with(@rdf:resource, 'http://pleiades')">
                    <a href="{substring-before(@rdf:resource, '#this')}"><xsl:value-of select="@rdf:resource"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a>
                </xsl:otherwise>
            </xsl:choose>
            </p>
    </xsl:template>
    
    <xsl:template match="dc:description">
        <p>Description: <span property="http://purl.org/dc/elements/1.1/description"><xsl:value-of select="normalize-space(.)"/></span></p>
    </xsl:template>
    
    <xsl:template match="relationship:*">
        <xsl:variable name="term" select="local-name()"/>
        <xsl:variable name="target" select="@resource"/>
        <xsl:variable name="heading">
            <xsl:choose>
                <xsl:when test="$term = 'childOf'">Child of: </xsl:when>
                <xsl:when test="$term = 'parentOf'">Parent of: </xsl:when>
                <xsl:otherwise><xsl:value-of select="$term"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <p><xsl:value-of select="$heading"/>
            <a property="http://purl.org/vocab/relationship/{$term}" href="{@resource}">
                <xsl:for-each select="//foaf:Person[@rdf:about = $target]">
                    <xsl:choose>
                        <xsl:when test="rdfs:label">
                            <xsl:value-of select="normalize-space(rdfs:label)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(foaf:name)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </a>
        </p>
    </xsl:template>
    
    <xsl:template match="owl:sameAs" mode="sameify">
        <li><a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a></li>
    </xsl:template>
    
    <xsl:template match="rdf:type[@rdf:resource]">
        <p>Type of resource: <a href="{@rdf:resource}"><xsl:value-of select="tokenize(@rdf:resource, '/')[last()]"/></a></p>
    </xsl:template>
    <xsl:template match="void:feature[not(preceding-sibling::void:feature)]">
        <h3>the following features are provided:</h3>
        <ul><xsl:for-each select="../void:feature">
            <li><a href="{@rdf:resource}">
                <xsl:choose>
                    <xsl:when test="@rdf:resource='http://www.w3.org/ns/formats/Turtle'">Turtle</xsl:when>
                    <xsl:when test="@rdf:resource='http://www.w3.org/ns/formats/RDF_XML'">RDF XML</xsl:when>
                    <xsl:otherwise><xsl:value-of select="@rdf:resource"/></xsl:otherwise>
                </xsl:choose>
            </a></li>
        </xsl:for-each></ul>
    </xsl:template>
    
    <xsl:template match="void:feature"/>
    
    <xsl:template match="void:vocabulary[not(preceding-sibling::void:vocabulary)]">
        <h3>the following vocabularies are used in this dataset:</h3>
        <ul><xsl:for-each select="../void:feature">
            <li><a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a></li>
        </xsl:for-each></ul>
    </xsl:template>
    
    <xsl:template match="void:vocabulary"/>
    
    <xsl:template match="void:dataDump[not(preceding-sibling::void:dataDump)]">
        <h3>the following data dumps are provided:</h3>
        <ul><xsl:for-each select="../void:dataDump">
            <li>
                <xsl:choose>
                    <xsl:when test="ends-with(@rdf:resource,'.csv')">Comma-Separated Value: </xsl:when>
                    <xsl:when test="ends-with(@rdf:resource,'.ttl')">Turtle: </xsl:when>
                    <xsl:when test="ends-with(@rdf:resource, 'rdf')">RDF XML: </xsl:when>
                </xsl:choose>
                <a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a></li>
        </xsl:for-each></ul>
        <p class="listnote">NB: text encoding in all files is UTF-8</p>
        
    </xsl:template>
    
    <xsl:template match="void:dataDump"/>
    
    <xsl:template match="dcterms:* | foaf:homepage[not(ancestor::foaf:Person)] | void:*">
        <p>
            <xsl:text></xsl:text><strong><xsl:value-of select="local-name()"/>:</strong><xsl:text> </xsl:text>
            
            <xsl:choose>
                <xsl:when test="@rdf:resource">
                    <xsl:variable name="target" select="@rdf:resource"/>
                    <xsl:choose>
                        <xsl:when test="//*[@rdf:about=$target]">
                            <xsl:apply-templates select="//*[@rdf:about=$target]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text></xsl:text><a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a><xsl:text></xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="child::*">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>
    
    <xsl:template match="foaf:Person">
        <span class="person">
            <xsl:text></xsl:text><xsl:value-of select="foaf:name"/><xsl:text></xsl:text>
            <xsl:if test="foaf:*[local-name() != 'name']">
                <xsl:text> (</xsl:text><xsl:apply-templates select="foaf:*[local-name() != 'name']"/><xsl:text>)</xsl:text>
            </xsl:if>
        </span>
    </xsl:template>
    
    <xsl:template match="foaf:homepage[ancestor::foaf:Person]">
        <xsl:text>homepage: </xsl:text><a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a><xsl:if test="following-sibling::foaf:*"><xsl:text>, </xsl:text></xsl:if>
    </xsl:template>
    
    
    <xsl:template match="*"/>
    
    <xsl:template name="cleanfilname">
        <xsl:param name="raw"/>
        <xsl:variable name="cooked" select="replace(translate(lower-case(tokenize(@rdf:about, '/')[last()]), '()_', '---'), '--', '-')"/>
        <xsl:choose>
            <xsl:when test="ends-with($cooked, '-')">
                <xsl:value-of select="substring($cooked, 1, string-length($cooked)-1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$cooked"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="cssandscripts">
        <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.9.0/build/reset-fonts-grids/reset-fonts-grids.css&amp;2.9.0/build/base/base-min.css"/> 
        <link rel="stylesheet" type="text/css" href="{$cssbase}screen.css" media="screen"/>
        <script src='http://isawnyu.github.com/awld-js/lib/requirejs/require.min.js' type='text/javascript'></script>
        <script src='http://isawnyu.github.com/awld-js/awld.js?autoinit' type='text/javascript'></script>        
    </xsl:template>
    
    <xsl:template name="extras">
        <xsl:param name="uri"/>
        <xsl:if test="//rdf:Description[@rdf:about=$uri and foaf:isPrimaryTopicOf[contains(@rdf:resource, 'en.wikipedia.org')]]">
            <div id="extras">
                <h2>Extras:</h2>
                <ul>
            <xsl:for-each select="//rdf:Description[@rdf:about=$uri and foaf:isPrimaryTopicOf[contains(@rdf:resource, 'en.wikipedia.org')]]">
                <xsl:variable name="target" select="tokenize(foaf:isPrimaryTopicOf[contains(@rdf:resource, 'en.wikipedia.org')]/@rdf:resource, '/')[last()]"/>
                <li><a href="http://www4.wiwiss.fu-berlin.de/flickrwrappr/photos/{$target}">Photos that may depict <xsl:value-of select="$target"/></a> according to <a href="http://www4.wiwiss.fu-berlin.de/flickrwrappr/">flickr wrappr</a></li>
            </xsl:for-each>
                </ul>
            </div>
            
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="htmlpersondoc">
        <xsl:param name="filename"/>
        <xsl:param name="rawname"/>
        <xsl:param name="vtitle"/>
        <xsl:param name="vpage"/>
        <xsl:result-document href="{$filename}" format="html">
            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
            <html>
                <xsl:variable name="uri" select="@rdf:about"/>
                <head>
                    <title>
                        <xsl:choose>
                            <xsl:when test="rdfs:label"><xsl:value-of select="normalize-space(rdfs:label[1])"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="normalize-space(foaf:name[1])"/></xsl:otherwise>
                        </xsl:choose>
                    </title>
                    <xsl:call-template name="cssandscripts"/>                        
                    <link rel="foaf:primaryTopic" href="{$uri}"/>
                    <link rel="canonical" href="{$docbase}{$filename}"/>
                    <link type="application/rdf+xml" rel="alternate" href="{$docbase}{$filename}/rdf"/>
                    <link type="text/turtle" rel="alternate" href="{$docbase}{$filename}/ttl"/>
                </head>
                <body>
                    <div class="persondoc">
                        <h1>
                            <xsl:choose>
                                <xsl:when test="rdfs:label">
                                    <xsl:value-of select="normalize-space(rdfs:label[1])"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="normalize-space(foaf:name[1])"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </h1>
                        <p>URI for this document: <a href="{$docbase}{$rawname}"><xsl:value-of select="$docbase"/><xsl:value-of select="$rawname"/></a></p>
                        <p>Primary URI for the resource described by this document: <a href="{$uri}"><xsl:value-of select="$uri"/></a></p>
                        <xsl:if test="owl:sameAs">
                            <h2>In addition to the primary URI, the following URIs also identify the resource described by this document:</h2>
                            <ul>
                                <xsl:for-each select="owl:sameAs">
                                    <xsl:sort/>
                                    <xsl:apply-templates select="." mode="sameify"/>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        <xsl:apply-templates/>
                        <h2>The following resources provide additional information about the resource described by this document:</h2>
                        <ul><xsl:for-each select="//rdf:Description[@rdf:about=$uri and foaf:isPrimaryTopicOf]">
                            <xsl:apply-templates select="foaf:isPrimaryTopicOf" mode="topic"/>
                        </xsl:for-each></ul>
                        <xsl:if test="//foaf:knows[@rdf:resource=$uri]">
                            <p>This individual is known to the following:</p>
                            <ul>
                                <xsl:for-each select="//foaf:knows[@rdf:resource=$uri]">
                                    <xsl:sort/>
                                    <li><a href="{../@rdf:about}"><xsl:value-of select="normalize-space(../foaf:name[1])"/></a></li>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        <xsl:call-template name="extras">
                            <xsl:with-param name="uri" select="$uri"/>
                        </xsl:call-template>
                        
                    </div>
                    <div id="footer">
                        <p>This document is part of the <a href="{$vpage}"><xsl:value-of select="$vtitle"/></a> dataset.</p>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>