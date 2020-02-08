<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <ns uri="http://docbook.org/ns/docbook" prefix="d"/>
    
    <let name="bib-ids" value="//d:bibliography//@xml:id"/>
    
    <pattern id="leading-whitespace" abstract="true">
        <rule context="$element">
            <report test="matches(., '^[\p{Zs}\s]')" role="warning"><name/> should not begin with whitespace</report>
        </rule>
    </pattern>
    
    <pattern is-a="leading-whitespace">
        <param name="element" value="d:programlisting | d:title"/>
    </pattern>
    
    <pattern id="programlisting">
        <rule context="d:programlisting">
            <sqf:fix id="programlisting-xml">
                <sqf:description>
                    <sqf:title>Sets the language to 'xml'</sqf:title>
                </sqf:description>
                <sqf:add match="." node-type="attribute" target="language">xml</sqf:add>
            </sqf:fix>
            <assert test="@language" role="warning" sqf:fix="programlisting-xml"><name/> should have a language attribute where possible, to enable syntax highlighting</assert>
        </rule>
        <rule context="d:programlisting/@language">
            <let name="allowed-langs" value="tokenize('bourne
                c
                cmake
                cpp
                csharp
                css
                delphi
                ini
                java
                javascript
                lua
                m2
                perl
                php
                python
                ruby
                sql1999
                sql2003
                sql92
                tcl
                upc
                xml', '\s')"/>
            <assert test=". = $allowed-langs">Value of language attribute should be one of: <value-of select="string-join($allowed-langs, ', ')"/>; got '<value-of select="."/>'</assert>            
        </rule>
        <rule context="d:programlisting/d:co">
            <assert test="preceding-sibling::node()[self::text() or self::*][matches(., '\s$')]" role="warning"><name/> should be preceded by whitespace</assert>
        </rule>
    </pattern>
    
    <pattern id="title">
        <rule context="d:title">
            <sqf:fix id="remove-emphasis">
                <sqf:description>
                    <sqf:title>Strips emphasis from titles</sqf:title>
                </sqf:description>
                <sqf:replace match="d:emphasis">
                    <sqf:copy-of select="node()"/>
                </sqf:replace>
            </sqf:fix>
            <report test="count(*) = 1 and node()[1][self::d:emphasis]" sqf:fix="remove-emphasis"><name/> must not be entirely wrapped in emphasis</report>
        </rule>
    </pattern>
    
    <pattern id="bibliography">
        <rule context="d:xref">
            <sqf:fix id="rename-xref">
                <sqf:description>
                    <sqf:title>Replaces element xref with biblioref</sqf:title>
                </sqf:description>
                <sqf:replace match="." node-type="element" target="biblioref">
                    <sqf:copy-of select="@*"/>
                </sqf:replace>
            </sqf:fix>
            <report test="@linkend = $bib-ids" sqf:fix="rename-xref">Cross-references to bibliography entries must use biblioref rather than <name/></report>
        </rule>
    </pattern>
    
</schema>