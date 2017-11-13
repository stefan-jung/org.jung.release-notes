![DOCTALES Logo](https://doctales.github.io/images/doctales-logo-without-subtitle.svg)

- - - -

org.doctales.release-notes
========================

[![license](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)

**org.doctales.release-notes** is a plugin for the [DITA-OT](http://dita-ot.github.io) that extends the **org.dita.pdf2** plugin to automatically create release-notes lists or tables from the [DITA 1.3 release-management domain elements](http://docs.oasis-open.org/dita/dita/v1.3/os/part3-all-inclusive/archSpec/technicalContent/releaseManagement-domain.html#dita_release_management_domain_topic).

> **Tip**: To learn more about the **release-management domain**, read the official [DITA 1.3 release management domain feature article](https://www.oasis-open.org/committees/download.php/56339/Release_Management_WP.pdf).


Installation
------------

```shell
dita --install https://github.com/doctales/org.doctales.release-notes/archive/master.zip
```

Usage
-----

Add a `<booklist type="change-historylist"/>` element as a child of a `<booklists>` element on your `<bookmap>`, for example:

```xml
<frontmatter>
    <booklists>
        <toc/>
        <booklist type="change-historylist"/>
    </booklists>
</frontmatter>
```

Publish a `pdf2` based PDF. You can optionally set the `changelist.style` property to `table` to publish the changes in a table format, for example:

```shell
dita --input your.ditamap --format pdf -Dchangelist.style=table
```