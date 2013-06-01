<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bibo="http://purl.org/ontology/bibo/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:owl="http://www.w3.org/2002/07/owl#" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:relationship="http://purl.org/vocab/relationship/"
    xmlns:void="http://rdfs.org/ns/void#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    exclude-result-prefixes="dcterms void xs relationship"
    
    version="2.0">
    
    <xsl:param name="where">pkg</xsl:param>
    <xsl:param name="docbase">http://www.paregorios.org/resources/roman-emperors/</xsl:param>
    <xsl:param name="cssbase"><xsl:value-of select="$docbase"/>css/</xsl:param>
    <xsl:output method="xhtml" indent="yes" name="html" omit-xml-declaration="no"/>
    <xsl:output method="xml" indent="yes" name="xml"  exclude-result-prefixes="xs relationship" />
    
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
                                <xsl:with-param name="vdset" select="$vdset"/>
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
        <xsl:param name="vdset"/>
        
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
            <xsl:value-of select="$where"/>/<xsl:value-of select="$filename"/><xsl:text>.html</xsl:text>
        </xsl:variable>
        <xsl:call-template name="htmlpersondoc">
            <xsl:with-param name="filename" select="$htmlfilename"/>
            <xsl:with-param name="rawname" select="$filename"/>
            <xsl:with-param name="vpage" select="$vpage"/>
            <xsl:with-param name="vtitle" select="$vtitle"/>
        </xsl:call-template>
        
        <!-- create the target rdf xml file for this person doc -->
        <xsl:variable name="rdffilename">
            <xsl:value-of select="$where"/>/<xsl:value-of select="$filename"/><xsl:text>.rdf</xsl:text>
        </xsl:variable>
        <xsl:call-template name="rdfpersondoc">
            <xsl:with-param name="filename" select="$rdffilename"/>
            <xsl:with-param name="rawname" select="$filename"/>
            <xsl:with-param name="vdset" select="$vdset"/>
        </xsl:call-template>
        
        
    </xsl:template>
    
    <xsl:template match="foaf:isPrimaryTopicOf" mode="topic">
        <xsl:variable name="uri" select="@rdf:resource"/>
        <xsl:variable name="rtitle" select="normalize-space(//rdf:Description[@rdf:about=$uri and dcterms:title][1]/dcterms:title[1])"/>
        <xsl:variable name="rdesc" select="normalize-space(//rdf:Description[@rdf:about=$uri and dcterms:description][1]/dcterms:description[1])"/>
        <xsl:variable name="parenturi" select="normalize-space(//rdf:Description[@rdf:about=$uri and dcterms:isPartOf][1]/dcterms:isPartOf/@rdf:resource)"/>
        <xsl:variable name="parentstitle" select="normalize-space(//rdf:Description[@rdf:about=$parenturi and bibo:shortTitle][1]/bibo:shortTitle[1])"/>
        <xsl:variable name="parentftitle" select="normalize-space(//rdf:Description[@rdf:about=$parenturi and dcterms:title][1]/dcterms:title[1])"/>
        
<!--        <xsl:variable name="desc" select="normalize-space($rdfdesc/dcterms:description)"/>
        <xsl:variable name="parent" select="normalize-space($rdfdesc/dcterms:isPartOf/@rdf:resource)"/>
        -->
        <li><a class="atitle" href="{$uri}"><xsl:value-of select="$rtitle"/></a> in <span class="title" title="{$parentftitle}"><xsl:choose><xsl:when test="$parentstitle != ''"><xsl:value-of select="$parentstitle"/></xsl:when><xsl:otherwise><xsl:value-of select="$parentftitle"/></xsl:otherwise></xsl:choose></span><xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of><span class="description"><xsl:value-of select="$rdesc"/></span></li>
    </xsl:template>
    
    <xsl:template match="foaf:name">
        <li class="name">“<xsl:value-of select="normalize-space(.)"/>”</li>
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
    
    <!-- <xsl:template match="dc:description">
        <p>Description: <span property="http://purl.org/dc/elements/1.1/description"><xsl:value-of select="normalize-space(.)"/></span></p>
    </xsl:template> -->
    
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
        <xsl:variable name="term" select="tokenize(@rdf:resource, '/')[last()]"/>
        <xsl:variable name="termspace" select="substring-before(@rdf:resource, $term)"/>
        <xsl:variable name="voname">
            <xsl:choose>
                <xsl:when test="$termspace =  'http://xmlns.com/foaf/0.1/'">foaf</xsl:when>
                <xsl:when test="$termspace = 'http://dbpedia.org/resource/'">dbpedia</xsl:when>
                <xsl:when test="$termspace = 'http://nomisma.org/id/'">nomisma</xsl:when>
                <xsl:when test="$termspace = 'http://purl.org/ontology/bibo/'">bibo</xsl:when>
                <xsl:otherwise><xsl:value-of select="substring-before(@rdf:resource, $term)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>“<xsl:value-of select="$term"/>” 
            
            ( <a href="{@rdf:resource}" title="definition of the term {$term} in the {$voname} vocabulary"><xsl:value-of select="$voname"/>:<xsl:value-of select="$term"/></a> ).</li>
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
        <ul><xsl:for-each select="../void:vocabulary">
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
        <!-- <xsl:if test="//rdf:Description[@rdf:about=$uri and foaf:isPrimaryTopicOf[contains(@rdf:resource, 'en.wikipedia.org')]]">
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
        -->
    </xsl:template>
    
    
    <xsl:template name="htmlpersondoc">
        <xsl:param name="filename"/>
        <xsl:param name="rawname"/>
        <xsl:param name="vtitle"/>
        <xsl:param name="vpage"/>
        
        <xsl:message>    writing <xsl:value-of select="$filename"/></xsl:message>
        
        <xsl:result-document href="{$filename}" format="html">
            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
            <html>
                <xsl:variable name="uri" select="@rdf:about"/>
                <head>
                    <title>
                        <xsl:call-template name="getdoctitle"/>
                    </title>
                    <xsl:call-template name="cssandscripts"/>                        
                    <link rel="foaf:primaryTopic" href="{$uri}"/>
                    <link rel="canonical" href="{$docbase}{$rawname}"/>
                    <link type="application/rdf+xml" rel="alternate" href="{$docbase}{$rawname}/rdf"/>
                    <!-- <link type="text/turtle" rel="alternate" href="{$docbase}{$rawname}/ttl"/> -->
                </head>
                <body>
                    <div class="persondoc">
                        <h1>
                            <xsl:call-template name="getdoctitle"/>
                        </h1>
                        <p><strong>Uniform Resource Identifier (URI)</strong> for this document: <a href="{$docbase}{$rawname}"><xsl:value-of select="$docbase"/><xsl:value-of select="$rawname"/></a></p>
                        <p>Primary URI for the resource described by this document: <a href="{$uri}"><xsl:value-of select="$uri"/></a></p>
                        <xsl:if test="//rdf:Description[@rdf:about=$uri]/owl:sameAs">
                            <h2>In addition to the primary URI, the following URIs also identify ( <a href="http://www.w3.org/TR/owl-ref/#sameAs-def" title="the definition of the term 'sameAs' in the OWL Web Ontology Language">owl:sameAs</a> ) the resource described by this document:</h2>
                            <ul>
                                <xsl:for-each select="//rdf:Description[@rdf:about=$uri]/owl:sameAs">
                                    <xsl:sort select="@rdf:resource"/>
                                    <xsl:apply-templates select="." mode="sameify"/>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        <xsl:if test="//rdf:Description[@rdf:about=$uri]/rdf:type">
                            <h2>The following resource <strong>types</strong> (<a href="http://www.w3.org/TR/rdf-schema/#ch_type" title="definition of the term 'type' in the RDF Vocabulary Description Language">rdf:type</a> ) have been associated with this resource:</h2>
                            <ul>
                                <xsl:for-each select="//rdf:Description[@rdf:about=$uri]/rdf:type">
                                    <xsl:sort select="tokenize(@rdf:resource, '/')[last()]"/>
                                    <xsl:sort select="@rdf:resource"/>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        <xsl:if test="//rdf:Description[@rdf:about=$uri]/foaf:name">
                            <h2>The following <strong>names</strong> (<a href="http://xmlns.com/foaf/spec/#term_name" title="definition of the term 'name' in the Friend-of-a-Friend (FOAF) vocabulary">foaf:name</a> ) have been associated with this resource:</h2>
                            <ul>
                                <xsl:for-each select="//rdf:Description[@rdf:about=$uri]/foaf:name">
                                    <xsl:sort/>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        <!-- <xsl:apply-templates select="//rdf:Description[@rdf:about=$uri]/*"/> -->
                        <h2>The following <strong>resources</strong> provide additional information about the resource described by this document ( <a href="http://xmlns.com/foaf/spec/#term_isPrimaryTopicOf" title="definition of the term 'isPrimaryTopicOf' in the FOAF Vocabulary">foaf:isPrimaryTopicOf</a> ):</h2>
                        <ul class="opened"><xsl:for-each select="//rdf:Description[@rdf:about=$uri]/foaf:isPrimaryTopicOf">
                            <xsl:sort select="//rdf:Description[@rdf:about=current()/@rdf:resource and dcterms:title][1]/dcterms:title[1]"/>
                            <xsl:apply-templates select="." mode="topic"/>
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
                        <a href="{$docbase}{$rawname}/rdf" title="metadata about this resource in RDF format"><img border="0" src="http://www.w3.org/RDF/icons/rdf_metadata_button.32"
                            alt="RDF Resource Description Framework Metadata Icon"/></a>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="rdfpersondoc">
        <xsl:param name="filename"/>
        <xsl:param name="rawname"/>
        
        <xsl:param name="vdset"/>
        
        <xsl:message>    writing <xsl:value-of select="$filename"/></xsl:message>
        
        <xsl:result-document href="{$filename}" format="xml">
            <xsl:element name="rdf:RDF" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" inherit-namespaces="no">
                <xsl:copy-of select="namespace::*"/>
                <xsl:namespace name="dcterms">http://purl.org/dc/terms/</xsl:namespace>
                <!-- write triples *about* the person based on the master file -->
                <xsl:apply-templates select="." mode="rdfout"/>
                <!-- write triples about this document based on the void document -->
                <xsl:element name="rdf:Description">
                    <xsl:copy-of select="namespace::*"/>
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="$docbase"/><xsl:value-of select="$rawname"/>
                    </xsl:attribute>
                    <xsl:call-template name="wtrip">
                        <xsl:with-param name="verb">foaf:primaryTopic</xsl:with-param>
                        <xsl:with-param name="objuri" select="./@rdf:about"/>
                    </xsl:call-template>
                    <xsl:call-template name="wtrip">
                        <xsl:with-param name="verb">rdf:type</xsl:with-param>
                        <xsl:with-param name="objuri">http://xmlns.com/foaf/0.1/Document</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="wtrip">
                        <xsl:with-param name="verb">rdfs:label</xsl:with-param>
                        <xsl:with-param name="objtext">
                            <xsl:call-template name="getdoctitle"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates select="$vdset/dcterms:creator" mode="rdfout"/>
                    <xsl:apply-templates select="$vdset/dcterms:contributor" mode="rdfout"/>
                    <xsl:apply-templates select="$vdset/dcterms:publisher" mode="rdfout"/>
                    <xsl:apply-templates select="$vdset/dcterms:created" mode="rdfout"/>
                    <xsl:apply-templates select="$vdset/dcterms:modified" mode="rdfout"/>
                    <xsl:apply-templates select="$vdset/dcterms:license" mode="rdfout"/>
                    <xsl:call-template name="wtrip">
                        <xsl:with-param name="verb">dcterms:isPartOf</xsl:with-param>
                        <xsl:with-param name="objuri" select="$vdset/foaf:homepage/@rdf:resource"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="getdoctitle">
        <xsl:text>About the Roman Emperor </xsl:text>
        <xsl:choose>
            <xsl:when test="rdfs:label"><xsl:value-of select="normalize-space(rdfs:label[1])"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="normalize-space(foaf:name[1])"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="wtrip">
        <xsl:param name="verb"/>
        <xsl:param name="objuri"/>
        <xsl:param name="objtext"/>
        <xsl:param name="nspaz"/>
        <xsl:param name="nspazuri"/>
        <xsl:element name="{$verb}">
            <xsl:choose>
                <xsl:when test="$nspaz">
                    <xsl:namespace name="{$nspaz}" select="$nspazuri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="namespace::*"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="$objuri">
                <xsl:attribute name="rdf:resource" select="$objuri"/>
            </xsl:if>
            <xsl:if test="$objtext">
                <xsl:value-of select="$objtext"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="rdfout">
        <xsl:variable name="uri" select="@rdf:about"/>
        <!-- gather up and write all the triples about this person -->        
        <xsl:element name="rdf:Description">
            <xsl:copy-of select="namespace::*"/>
            <xsl:attribute name="rdf:about" select="$uri"/>
            <xsl:apply-templates select="//rdf:Description[@rdf:about=$uri]/*" mode="rdfout">
                <xsl:sort select="substring-before(name(), ':')"/>
                <xsl:sort select="local-name(.)"/>
                <xsl:sort select="@rdf:resource"/>
                <xsl:sort select="lower-case(normalize-space(.))"/>
            </xsl:apply-templates>
        </xsl:element>
        <!-- write related triples -->
        <xsl:for-each select="//rdf:Description[@rdf:about=$uri]">
            <xsl:for-each select="*[@rdf:resource]">
                <xsl:variable name="relateduri" select="@rdf:resource"/>
                <xsl:for-each select="//rdf:Description[@rdf:about=$relateduri][1]">
                    <xsl:element name="rdf:Description">
                        <xsl:copy-of select="namespace::*"/>
                        <xsl:attribute name="rdf:about" select="$relateduri"/>
                        <xsl:apply-templates select="//rdf:Description[@rdf:about=$relateduri]/*" mode="rdfout">
                            <xsl:sort select="substring-before(name(), ':')"/>
                            <xsl:sort select="local-name(.)"/>
                            <xsl:sort select="@rdf:resource"/>
                            <xsl:sort select="lower-case(normalize-space(.))"/>
                        </xsl:apply-templates>
                    </xsl:element>
                </xsl:for-each>
                </xsl:for-each>
            
        </xsl:for-each>
        
    </xsl:template>
        
    <xsl:template match="*" mode="rdfout">
        <xsl:copy-of select="." copy-namespaces="no"  />
        <!-- add schema.org types -->
        <xsl:if test="local-name()='type'">
            <xsl:choose>
                <xsl:when test="@rdf:resource='http://purl.org/ontology/bibo/Webpage'">
                    <rdf:type rdf:resource="http://schema.org/WebPage">
                        <xsl:copy-of select="namespace::*"/>
                    </rdf:type>
                </xsl:when>
                <xsl:when test="@rdf:resource='http://xmlns.com/foaf/0.1/Person'">
                    <rdf:type rdf:resource="http://schema.org/Person">
                        <xsl:copy-of select="namespace::*"/>
                    </rdf:type>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <!-- <xsl:copy inherit-namespaces="no" copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="* | text()" mode="rdfout"/>
        </xsl:copy> -->
        <!-- <xsl:variable name="prefix" select="substring-before(name(), ':')"/>
        <xsl:element name="{$prefix}:{local-name()}" inherit-namespaces="no">
            <xsl:namespace name="{$prefix}" select="namespace-uri()"/>
            <xsl:copy-of select="@*"/>
            
            <xsl:apply-templates select="text() | *" mode="rdfout" />
        </xsl:element> -->
    </xsl:template>
    
    
    
</xsl:stylesheet>