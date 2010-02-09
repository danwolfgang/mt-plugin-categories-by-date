# Overview

Categories are not a date-related object in MT, so publishing categories in a date-structured way isn't possible.

The CategoriesByDate plugin adds a block tag that will sort categories by date, with the most recently updated first. To determine the order of the categories, each category is compared to newest entry it is used in and that entry's date sorts the category.

# Use

This plugin adds the <code>&lt;mt:CategoriesByDate&gt;...&lt;/mt:CategoriesByDate&gt;</code> block tag, which creates a category context. The following is a simple example of its use, and will return an unordered list of categories sorted by the date of their last use.

    <mt:CategoriesByDate>
        <mt:If name="__first__">
        <ul>
        </mt:If>
            <li><mt:CategoryLabel></li>
        <mt:If name="__last__">
        </ul>
        </mt:If>
    </mt:CategoriesByDate>

CategoriesByDate can also take a few arguments to help you refine the tag's results:

* The <code>top</code> argument can be set to a value of <code>1</code>. This will return only the top-level categories.
* The <code>include\_children</code> argument can be set to a value of <code>1</code>. This will cause the current category's subcategories and their contents to be considered when determining the current category's date.
* The <code>limit</code> argument can be set to a positive number to limit the number of results returned, making it easy to create a list of the five recently-active categories, for example.

Below is an example that makes use of all of these arguments. Only the top-level categories are returned, but all subcategories are considered when determining the order of the top-level categories. Only the first 5 categories are returned. A link to the newest entry in that category is also published.

    <mt:CategoriesByDate top="1" include_children="1" limit="5">
        <mt:If name="__first__">
        <ul>
        </mt:If>
            <li>
                <span class="category"><a href="<mt:CategoryArchiveLink>"><mt:CategoryLabel></a></span>:
                <mt:CategoryLabel setvar="current_category">
                <span class="entry"><mt:Entries category="$current_category" lastn="1"><a href="<mt:EntryPermalink>"><mt:EntryTitle></a></mt:Entries></span>
            </li>
        <mt:If name="__last__">
        </ul>
        </mt:If>
    </mt:CategoriesByDate>

# Acknowledgements

This plugin was commissioned by The Roster, a web marketing and design team, to Dan Wolfgang of uiNNOVATIONS.

* [http://theroster.com](http://theroster.com)
* [http://uinnovations.com](http://uinnovations.com)

# License

This plugin is licensed under the same terms as Perl itself.

Copyright 2010, uiNNOVATIONS LLC.
