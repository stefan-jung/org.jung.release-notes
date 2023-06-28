<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:sj="https://stefanjung.netlify.app"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    exclude-result-prefixes="dita-ot ot-placeholder opentopic opentopic-index opentopic-func dita2xslfo sj xs"
    version="2.0">
    
    <!-- Style of the change list, allowed values: 'list' and 'table' -->
    <xsl:param name="changelist.style" select="'list'" as="xs:string"/>

    <!-- The variable change-items contains a list of all change-item elements that have a change-completed date. -->
    <xsl:variable
        name="change-items"
        select="//*[contains (@class, ' relmgmt-d/change-item ')][*[contains (@class, ' relmgmt-d/change-completed ')] != '']"
    />
    
    <!-- Keep date format in a variable -->
    <xsl:variable name="dateFormat" as="xs:string">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'#date-format'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:function name="sj:bookReleaseHasChangeItems" as="xs:boolean">
        <xsl:param name="previousReleaseDate" as="xs:date"/>
        <xsl:param name="releaseDate" as="xs:date"/>
        
        <xsl:variable name="validChangeItems">
            <xsl:for-each select="$change-items">
                <xsl:variable
                    name="completionDate"
                    select="xs:date(*[contains (@class, ' relmgmt-d/change-completed ')])"
                />
                <xsl:choose>
                    <xsl:when test="(($previousReleaseDate &lt;= $completionDate) and ($completionDate &lt;= $releaseDate))">
                        <xsl:value-of select="'true'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'false'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="hasValidItem">
            <xsl:choose>
                <xsl:when test="contains($validChangeItems, 'true')">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$hasValidItem"/>
    </xsl:function>
    
    <!-- Add new list, following the pattern in topicmergeImpl.xsl -->
    <xsl:template match="*[contains(@class,' bookmap/booklist ')][@type='change-historylist'][not(@href)]" priority="2" mode="build-tree">
        <ot-placeholder:tablelist id="{generate-id()}">
            <xsl:apply-templates mode="build-tree"/>
        </ot-placeholder:tablelist>
    </xsl:template>
    
    <xsl:template match="ot-placeholder:changelist" mode="bookmark">
        <xsl:if test="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ' )]">
            <fo:bookmark internal-destination="{$id.lot}">
                <xsl:if test="$bookmarkStyle!='EXPANDED'">
                    <xsl:attribute name="starting-state">hide</xsl:attribute>
                </xsl:if>
                <fo:bookmark-title>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'List of Changes'"/>
                    </xsl:call-template>
                </fo:bookmark-title>
                
                <xsl:apply-templates mode="bookmark"/>
            </fo:bookmark>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ot-placeholder:changelist" name="createChangeList">
        <xsl:if test="//*[contains(@class, ' relmgmt-d/change-historylist ')]">
            <fo:page-sequence master-reference="toc-sequence" xsl:use-attribute-sets="page-sequence.loc">
                <xsl:call-template name="insertTocStaticContents"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block start-indent="0in">
                        <xsl:call-template name="createLOCHeader"/>
                        <xsl:apply-templates select="//*[contains(@class, ' topic/critdates ')][1]"/>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="createLOCHeader">
        <fo:block xsl:use-attribute-sets="__lotf__heading" id="{$id.lot}">
            <fo:marker marker-class-name="current-header">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'List of Changes'"/>
                </xsl:call-template>
            </fo:marker>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'List of Changes'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' topic/critdates ')]">
        
        <!-- Create a list of all book releases -->
        <xsl:variable
            name="bookReleaseDates"
            select="*[contains (@class, ' topic/created ')]/@date | *[contains (@class, ' topic/revised ')]/@modified"
        />
                
        <fo:block-container>
            <fo:block>
                <xsl:call-template name="commonattributes"/>
                <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
                
                <xsl:for-each select="$bookReleaseDates">
                    <xsl:variable
                        name="previousDateIndex"
                        select="position() - 1"
                        as="xs:integer"
                    />
                    
                    <!-- 
                        If no previous book release date exists,
                        because it is the first release,
                        create a dummy date.
                    -->
                    <xsl:variable
                        name="previousBookReleaseDate"
                        as="xs:date">
                        <xsl:choose>
                            <xsl:when test="exists($bookReleaseDates[$previousDateIndex])">
                                <xsl:value-of select="$bookReleaseDates[$previousDateIndex]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'1970-01-01'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable
                        name="currentBookReleaseDate"
                        select="xs:date(.)"
                        as="xs:date"
                    />

                    <fo:block xsl:use-attribute-sets="section.title change-list.section.title">
                        <xsl:call-template name="commonattributes"/>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Book Release Date'"/>
                        </xsl:call-template>
                        <xsl:value-of select="format-date($currentBookReleaseDate, $dateFormat)"/>
                    </fo:block>
                    
                    <xsl:if test="sj:bookReleaseHasChangeItems($previousBookReleaseDate, $currentBookReleaseDate)">
                        
                        <xsl:choose>
                            
                            <!-- The property changelist.style=list (default) has been set -->
                            <xsl:when test="$changelist.style eq 'list'">
                                <fo:list-block xsl:use-attribute-sets="ul">
                                    <xsl:for-each select="$change-items">
                                        
                                        <xsl:variable
                                            name="changeItemCompletionDate"
                                            select="xs:date(*[contains (@class, ' relmgmt-d/change-completed ')])"
                                        />
                                        
                                        <xsl:variable
                                            name="isValidChangeItem"
                                            select="(($previousBookReleaseDate &lt;= $changeItemCompletionDate) and ($changeItemCompletionDate &lt;= $currentBookReleaseDate))
                                            or (($changeItemCompletionDate &lt;= xs:date($bookReleaseDates[1])) and ($currentBookReleaseDate = xs:date($bookReleaseDates[1])))"
                                        />
                                        
                                        <xsl:if test="$isValidChangeItem">
                                            
                                            <fo:list-item xsl:use-attribute-sets="ul.li">
                                                
                                                <fo:list-item-label xsl:use-attribute-sets="ul.li__label">
                                                    <fo:block xsl:use-attribute-sets="ul.li__label__content">
                                                        <xsl:call-template name="getVariable">
                                                            <xsl:with-param name="id" select="'Unordered List bullet'"/>
                                                        </xsl:call-template>
                                                    </fo:block>
                                                </fo:list-item-label>
                                                
                                                <fo:list-item-body xsl:use-attribute-sets="ul.li__body">
                                                    <fo:block xsl:use-attribute-sets="ul.li__content change-list.entry">
                                                        
                                                        <!-- You can move or disable template calls to change the appearance -->
                                                        <xsl:apply-templates
                                                            select="*[contains(@class, ' relmgmt-d/change-summary ')]" 
                                                            mode="relmgmt-list"
                                                        />
                                                        <xsl:apply-templates
                                                            select="*[contains(@class, ' relmgmt-d/change-revisionid ')]"
                                                            mode="relmgmt-list"
                                                        />
                                                        <xsl:apply-templates
                                                            select="*[contains(@class, ' relmgmt-d/change-organization ')]" 
                                                            mode="relmgmt-list"
                                                        />
                                                        <xsl:apply-templates
                                                            select="*[contains(@class, ' relmgmt-d/change-person ')]" 
                                                            mode="relmgmt-list"
                                                        />
                                                        <xsl:apply-templates
                                                            select="*/*[contains(@class, ' relmgmt-d/change-request-system ')]"
                                                            mode="relmgmt-list"
                                                        />
                                                        <xsl:apply-templates
                                                            select="*/*[contains(@class, ' relmgmt-d/change-request-id ')]"
                                                            mode="relmgmt-list"
                                                        />
                                                        <xsl:apply-templates
                                                            select="*[contains(@class, ' relmgmt-d/change-started ')]"
                                                            mode="relmgmt-list"
                                                        />
                                                        <xsl:apply-templates
                                                            select="*[contains(@class, ' relmgmt-d/change-completed ')]"
                                                            mode="relmgmt-list"
                                                        />
                                                        
                                                    </fo:block>
                                                </fo:list-item-body>
                                            </fo:list-item>
                                            
                                        </xsl:if>
                                    </xsl:for-each>
                                </fo:list-block>
                            </xsl:when>
                            
                            <!-- The property changelist.style=table has been set -->
                            <xsl:when test="$changelist.style eq 'table'">
                                <fo:table xsl:use-attribute-sets="change-table">
                                    <fo:table-header xsl:use-attribute-sets="change-table.header">
                                        <fo:table-row xsl:use-attribute-sets="change-table.header.row">
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Summary'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Revision ID'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Requested By'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Changed By'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Request System'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Request ID'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Started'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell xsl:use-attribute-sets="change-table.header.row.cell">
                                                <fo:block>
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Release Notes Table Completed'"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </fo:table-cell>
                                        </fo:table-row>
                                    </fo:table-header>
                                    <fo:table-body xsl:use-attribute-sets="change-table.body">
                                        
                                        <xsl:for-each select="$change-items">
                                            
                                            <xsl:variable
                                                name="changeItemCompletionDate"
                                                select="xs:date(*[contains (@class, ' relmgmt-d/change-completed ')])"
                                            />
                                            
                                            <xsl:variable
                                                name="isValidChangeItem"
                                                select="(($previousBookReleaseDate &lt;= $changeItemCompletionDate) and ($changeItemCompletionDate &lt;= $currentBookReleaseDate))
                                                or (($changeItemCompletionDate &lt;= xs:date($bookReleaseDates[1])) and ($currentBookReleaseDate = xs:date($bookReleaseDates[1])))"
                                            />
                                            
                                            <xsl:if test="$isValidChangeItem">
                                                
                                                <fo:table-row xsl:use-attribute-sets="change-table.body.row">
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*[contains(@class, ' relmgmt-d/change-summary ')]" 
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*[contains(@class, ' relmgmt-d/change-revisionid ')]" 
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*[contains(@class, ' relmgmt-d/change-organization ')]" 
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*[contains(@class, ' relmgmt-d/change-person ')]" 
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*/*[contains (@class, ' relmgmt-d/change-request-system ')]" 
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*/*[contains (@class, ' relmgmt-d/change-request-id ')]" 
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*[contains(@class, ' relmgmt-d/change-started ')]"
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell xsl:use-attribute-sets="change-table.body.row.cell">
                                                        <fo:block>
                                                            <xsl:apply-templates
                                                                select="*[contains(@class, ' relmgmt-d/change-completed ')]"
                                                                mode="relmgmt-table"
                                                            />
                                                        </fo:block>
                                                    </fo:table-cell>
                                                </fo:table-row>
                                                
                                            </xsl:if>
                                            
                                        </xsl:for-each>

                                    </fo:table-body>
                                </fo:table>

                            </xsl:when>
                            
                            <xsl:otherwise>
                                <xsl:message terminate="yes">
                                    [ERROR] Invalid changelist.style value:
                                    <xsl:value-of select="$changelist.style"/>
                                </xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
                <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>
    
    
    <!-- relmgmt-table -->
    <xsl:template match="*[contains(@class, ' relmgmt-d/change-item ')]" mode="relmgmt-table">
        <xsl:apply-templates mode="relmgmt-table"/>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-organization ')]" mode="relmgmt-table">
        <fo:block>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-person ')]" mode="relmgmt-table">
        <fo:block>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-revisionid ')]" mode="relmgmt-table">
        <fo:block>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*/*[contains (@class, ' relmgmt-d/change-request-system ')]" mode="relmgmt-table">
        <fo:block>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*/*[contains (@class, ' relmgmt-d/change-request-id')]" mode="relmgmt-table">
        <fo:block>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-started ')]" mode="relmgmt-table">
        <fo:block>
            <xsl:value-of select="format-date(., $dateFormat)"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-completed ')]" mode="relmgmt-table">
        <fo:block>
            <xsl:value-of select="format-date(., $dateFormat)"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-summary ')]" mode="relmgmt-table">
        <fo:block>
             <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    
    <!-- relmgmt-list -->
    <xsl:template name="changeListComponent">
        <xsl:param name="elementName" as="xs:string"></xsl:param>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' relmgmt-d/change-item ')]" mode="relmgmt-list">
        <xsl:apply-templates mode="relmgmt-list"/>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-organization ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.requested-by.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Requested By'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.content change-list.requested-by.content">
            <xsl:value-of select="."/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-person ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.changed-by.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Changed By'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.content change-list.changed-by.content">
            <xsl:value-of select="."/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-revisionid ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.revision-id.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Revision ID'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.content change-list.revision-id.content">
            <xsl:value-of select="."/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-started ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-started.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Started'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-started.content">
            <xsl:value-of select="format-date(., $dateFormat)"/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-completed ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-completed.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Completed'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-completed.content">
            <xsl:value-of select="format-date(., $dateFormat)"/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' relmgmt-d/change-request-system ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-request-system.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Request System'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-request-system.content">
            <xsl:value-of select="."/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' relmgmt-d/change-request-id ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-request-id.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Request ID'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-request-id.label">
            <xsl:value-of select="."/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains (@class, ' relmgmt-d/change-summary ')]" mode="relmgmt-list">
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-summary.label">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Release Notes List Summary'"/>
            </xsl:call-template>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="change-list.label change-list.change-summary.content">
            <xsl:value-of select="."/>
        </fo:inline>
    </xsl:template>

</xsl:stylesheet>