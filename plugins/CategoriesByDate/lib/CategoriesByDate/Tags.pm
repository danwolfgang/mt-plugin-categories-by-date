package CategoriesByDate::Tags;

use strict;

use base qw( MT::App );

sub categories_by_date_block {
    my ($ctx, $args, $cond) = @_;
    my $app = MT->instance;
    my $builder = $ctx->stash('builder');
    my $tokens  = $ctx->stash('tokens');
    my $res = '';
    my %terms;

    use MT::Category;
    use MT::Placement;
    use MT::Entry;
    
    # First we need to set the parameters to load the proper categories.
    if ($args->{top}) {
        $terms{parent} = '0';
    }
    if ($args->{category}) {
        my $category = MT::Category->load({ label => $args->{category}, });
        if ($category) {
            $terms{parent} = $category->id;
        }
    }

    $terms{blog_id} = $app->blog->id;
    $terms{class}   = 'category';

    # Load all of the categories.
    my %dated_categories;
    my $cat_iter = MT::Category->load_iter(\%terms);
    while ( my $category = $cat_iter->() ) {
        # Check if this is a valid category to be included. The recently-used
        # date is returned.
        $dated_categories{$category->id} = _category_last_used($category);

        # Do we need to check in child categories should help determine the sort order?
        if ($args->{include_children}) {
            # No need to respecify all of the terms for the initial load--the child
            # category *must* match the terms because the parent category does.
            my $child_iter = MT::Category->load_iter({ parent => $category->id, });
            while ( my $child_cat = $child_iter->() ) {
                # Only if the child category has a newer date than the parent
                # do we update the hash.
                if ( _category_last_used($child_cat) > $dated_categories{$category->id} ) {
                    $dated_categories{$category->id} = _category_last_used($child_cat);
                }
            }
        }
    }

    # Now we have a hash of the category IDs and the date they were used on.
    # Sort them into an array.
    my @cats = sort { $dated_categories{$b} <=> $dated_categories{$a} } keys %dated_categories;
    
    # If a limit has been specified, cut the array to the argument specified.
    if ($args->{limit}) {
        # Subtract 1 from the supplied limit because the array index starts at 0, not 1.
        my $limit = $args->{limit} - 1;
        @cats = @cats[0..$limit];
    }
    
    # Now, build the template loop.
    my $i = 0;
    my $vars = $ctx->{__stash}{vars} ||= {};

    foreach my $cat (@cats) {
        # Assign the meta vars
        local $vars->{__first__} = !$i;
        local $vars->{__last__} = !defined $cats[$i + 1];
        local $vars->{__odd__} = ($i % 2) == 0; # 0-based $i
        local $vars->{__even__} = ($i % 2) == 1;
        local $vars->{__counter__} = $i + 1;

        my $category = MT::Category->load($cat);
        next unless ($category);
        use MT::Promise qw(delay);
        $ctx->{__stash}{category} = $category if $@;
        $ctx->{__stash}{category} = delay (sub { $category; }) unless $@;
        my $out = $builder->build($ctx, $tokens);
        return $ctx->error($builder->errstr) unless defined $out;
        $res .= $out;
        
        $i++;
    }
    
    return $res;
}

sub _category_last_used {
    my ($category) = @_;
    my $app = MT->instance;
    # Now find which entries this category was used in. Sort by 'descend'
    # so that we get an ordered result with the most recent use first.
    # We need to grab more than just the single most recent result,
    # though, because the entry may be 'unpublished'.
    use MT::Placement;
    my $placement_iter = MT::Placement->load_iter({ blog_id     => $app->blog->id,
                                                    category_id => $category->id, },
                                                  { direction => 'descend', });
    while ( my $placement = $placement_iter->() ) {
        # Now that we know where the category was used, load that entry.
        my $entry = MT::Entry->load( $placement->entry_id );
        # And now verify that this entry is actually published.
        if ( $entry->status == MT::Entry::RELEASE() ) {
            #MT->log($category->id.': '.$category->label.' used on '.$entry->modified_on);
            return $entry->modified_on;
        }
    }
}

1;

__END__

<mt:CategoriesByDate top="1" include_children="1" limit="5">
    <mt:If name="__first__">
    <ul>
    </mt:If>
        <li><mt:CategoryLabel></li>
    <mt:If name="__last__">
    </ul>
    </mt:If>
</mt:CategoriesByDate>
