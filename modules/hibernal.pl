#!/usr/bin/env perl
# ====================[ hibernal.pl                        ]====================

=head1 NAME

hibernal - An Oddmuse module for improved multi- and single-blogging.

=head1 SYNOPSIS

hibernal extends Oddmuse (and, optionally, Oddmuse's Calendar and SmartTitles
extensions) with reliable, scaleable support for both multi-blogging - in which
one Oddmuse Wiki hosts multiple blogs, each blog singly, separately authored by
one Oddmuse Wiki user - and single-blogging - in which one Oddmuse Wiki hosts
one and only one blog.

=head1 INSTALLATION

hibernal is simply installable; simply:

=over

=item 1. Save this file to the B<wiki/modules/> directory of your Oddmuse Wiki.

=item 2. Optionally, download and install the Calendar extension; see:
         http://www.oddmuse.org/cgi-bin/oddmuse/Calendar_Extension

=item 3. Optionally, download and install the Smarttitles extension; see:
         http://www.oddmuse.org/cgi-bin/oddmuse/Smarttitles_Extension

=back

Optionally downloading and installing the Calendar extension adds archive
functionality to hibernal. Specifically, it adds a "Posts archive" link to the
foot of every hibernal page that, when browsed to, prints a year-navigable
calendar consisting of all blog posts for this blog.

Optionally downloading and installing the SmartTitles extensions adds subtitle
functionality to hibernal. Specifically, it adds a "Year ${CURRENT_YEAR}"
subtitle to each hibernal archive page; and prints subtitles for each blog post,
for posts having such a subtitle.

=cut
# FIXME: to add to Hibernal: correct Oddmuse's failure to link comment author-names
#     having spaces; e.g., entering a username of "David Curry" should auto-link to
#     "David_Curry".
package OddMuse;

$ModulesDescription .= '<p>$Id: hibernal.pl,v 1.4 2008/10/11 13:06:44 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

hibernal is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($HibernalTitleOrSubtitleSuffix
            $HibernalArchiveTitleOrSubtitleSuffix

            $HibernalNewPostLinkText
            $HibernalNewerPostsLinkText
            $HibernalOlderPostsLinkText
            $HibernalArchiveLinkText
            $HibernalArchiveYearLinkText
            $HibernalPostCommentsLinkText
            $HibernalPostCommentsCreateLinkText
            $HibernalPostCommentsDemarcatorMarkup
            $HibernalPostCommentsAuthorshipMarkup

            $HibernalDefaultPostNameRegexp
            $HibernalDefaultPostsPerPage $HibernalMaximumPostsPerPage
            $HibernalDefaultTitle        $HibernalDefaultSubtitle
            $HibernalDefaultArchiveTitle $HibernalDefaultArchiveSubtitle

            $HibernalIsCurrentlyPrinting
          );

=head2 $HibernalTitleOrSubtitleSuffix

A string to to be appended the title or subtitle, as appropriate, for each
hibernal page. This string provides explanatory context for that page. Now,
here's how it works: if that page provides a subtitle, hibernal appends this
string to its subtitle; otherwise, hibernal appends this string to its title.
This prioritization is necessary, so as to keep the SmartTitles extension an
only optional dependency of this extension.

hibernal performs variable substitution on this string, as follows:

=over

=item The first '%s' in this string, if present, is replaced with the index of
      the first blog post to be displayed for this hibernal page.

=item The second '%s' in this string, if present, is replaced with the index of
      the last blog post to be displayed for this hibernal page.

=back

=cut
$HibernalTitleOrSubtitleSuffix = ' ~ Posts %s — %s';

=head2 $HibernalArchiveTitleOrSubtitleSuffix

A string to to be appended the title or subtitle, as appropriate, for each
hibernal archive page. This string provides explanatory context for that page,
and is context-sensitively applied as in the C<HibernalTitleOrSubtitleSuffix>,
above.

hibernal performs variable substitution on this string, as follows:

=over

=item The first '%s' in this string, if present, is replaced with the year
      currently being viewed in this hibernal archive page.

=back

=cut
$HibernalArchiveTitleOrSubtitleSuffix = ' ~ Posts for %s';

=head2 $HibernalNewPostLinkText

The text for the navigational link to create new blog posts (at the foot of each
hibernal page), if the current user is authorized to create such a post. If the
current user is not authorized to create such a post, hibernal displays nothing.

=cut
$HibernalNewPostLinkText = 'New post';

=head2 $HibernalOlderPostsLinkText

The text for the navigational link to older blog posts (at the foot of each
hibernal page).

=cut
$HibernalOlderPostsLinkText = 'Older posts...';

=head2 $HibernalNewerPostsLinkText

The text for the navigational link to newer blog posts (at the foot of each
hibernal page).

=cut
$HibernalNewerPostsLinkText = 'Newer posts...';

=head2 $HibernalArchiveLinkText

The text for the navigational link to the hibernal archive (at the foot of each
hibernal page), if the Calender extension is installed.

=cut
$HibernalArchiveLinkText = 'Posts archive!';

=head2 $HibernalArchiveYearLinkText

The text for each year-specific navigational link at the head of each hibernal
archive page.

hibernal dynamically peruses the set of all blog posts matched by this archive
and, for each calendar year for that archive having at least one blog post,
displays a navigational link to that archive year at the top of each hibernal
archive page.

hibernal performs variable substitution on this text, as follows:

=over

=item The first '%s' in this text, if present, is replaced with the year
      currently being linked to.

=back

=cut
$HibernalArchiveYearLinkText = '%s...';

=head2 $HibernalPostCommentLinkText

The text for the navigational link to add a comment to the current blog post
(at the foot of that post).

=cut
$HibernalPostCommentLinkText = 'Add a comment...';

=head2 $HibernalPostCommentsLinkText

The text for the navigational link to the comments for the current blog post
(at the foot of that post), for posts having at least one comment. Note that,
as Oddmuse displays these comments on a page having at its foot an edit box for
adding some comments, we needn't build a separate navigational link for that.

=cut
$HibernalPostCommentsLinkText = 'Comments';

=head2 $HibernalPostCommentsCreateLinkText

The text for the navigational link to create the comments for the current blog
post (at the foot of that post), for posts having no existing comments.

=cut
$HibernalPostCommentsCreateLinkText = 'Comment on this post';

=head2 $HibernalPostCommentsDemarcatorMarkup

Markup for demarcating blog post comments from each other. As Oddmuse
concentrates all blog post comments for a blog post on one Wiki page, hibernal
must provide some markup for differentiating where one blog post comment ends
and another begins. That's what this is.

Specifically, this markup is prepended to all blog post comments for a blog post
(except the first blog post comment for that blog post, since no comments
precede it.)

This is Wiki markup; hibernal expands this text to HTML by applying all Oddmuse
markup rules to it, just as it does for "normal" Wiki page text. (The default
value for this text usually expands to an </hr> tag.)

=cut
$HibernalPostCommentsDemarcatorMarkup = qq`----\n`;

=head2 $HibernalPostCommentsAuthorshipMarkup

Markup for demarcating the author of a blog post comment from the body text of
that blog post comment. Typically, this includes that author’s name, an optional
link to that author’s external homepage or internal Wiki page, and the time at
which that author added that comment.

For customizability, Hibernal performs blog post comment-specific variable
substitution on this markup; this is:

=over

=item The first '%s' in this markup, if present, is replaced with that author.

=item The first '%s' in this markup, if present, is replaced with that time.

=back

This is Wiki markup; Hibernal expands this text to HTML by applying all Oddmuse markup rules to it, just as it does for “normal” Wiki page text. The default value for this text depends on which other markup extensions are also installed. The algorithm is as follows:

=over

=item If the Creole Additions markup extension is installed, this markup
      defaults to C<qq`\n\n"""\n%s. %s.\n"""`> -- a blockquote having a bold
      author and non-bold time.

=item Otherwise, if the Creole markup extension is installed, this markup
      defaults to C<qq`\n\n|%s. %s.|`> -- a table having a bold author and
      non-bold time.

=item Otherwise, if the Usemod markup extension is installed, this markup
      defaults to C<qq`\n\n||%s. %s.||> -- a table having a bold author and
      non-bold time.

=item Otherwise, if the Markup extension is installed, this markup defaults to
      C<qq`\n\n⇒ **%s.** %s.`>.

=item Otherwise, if all else fails, this markup defaults to a simple
      C<qq`\n\n⇒ %s. %s.`>.

=back

=cut
$HibernalPostCommentsAuthorshipMarkup = undef;

# ....................{ CONFIGURATION =defaults            }....................

=head2 $HibernalDefaultPostNameRegexp

The default regular expression for matching blog post page names.

This variable is only a fail-safe; hibernal only applies it to <hibernal...>
markup having no such regular expression.

=cut
$HibernalDefaultPostNameRegexp = '^\d\d\d\d-\d\d-\d\d';

=head2 $HibernalDefaultPostsPerPage

The default number of blog posts to display per hibernal page. This number is
overwritable on a per-blog basis; simply add the desired number of blog posts
to the <hibernal...> markup for that page, ala:

  <hibernal "User1--Blog--\d\d\d\d-\d\d-\d\d" 0 16>

=cut
$HibernalDefaultPostsPerPage = 8;

=head2 $HibernalMaximumPostsPerPage

The maximum number of blog posts to display per hibernal page. This number is
not overwritable on a per-blog basis; it serves as a "hard limit" to prevent
abuse of <hibernal...> markup.

=cut
$HibernalMaximumPostsPerPage = 16;

=head2 $HibernalDefaultTitle

The default title for each hibernal page.

This variable is only a fail-safe; hibernal only applies it when failing to
dynamically parse the proper title from the prior hibernal page. Therefore,
you shouldn't need to redefine it.

=cut
$HibernalDefaultTitle = 'Blog';

=head2 $HibernalDefaultSubtitle

The default subtitle for each hibernal page.

This variable is only a fail-safe; hibernal only applies it when failing to
dynamically parse the proper subtitle from the prior hibernal page. Therefore,
you shouldn't need to redefine it.

=cut
$HibernalDefaultSubtitle = '';

=head2 $HibernalDefaultArchiveTitle

The default title for each hibernal archive page.

This variable is only a fail-safe, as above.

=cut
$HibernalDefaultArchiveTitle = 'Blog Archive';

=head2 $HibernalDefaultArchiveSubtitle

The default subtitle for each hibernal archive page.

This variable is only a fail-safe, as above.

=cut
$HibernalDefaultArchiveSubtitle = '';

# ....................{ INITIALIZATION                     }....................
my ($second_now, $minute_now, $hour_now, $day_now, $month_now, $year_now,
    $is_calendar_installed,
    $is_creoleaddition_installed,
    $is_smarttitles_installed);

push(@MyInitVariables, \&HibernalInit);

sub HibernalInit {
  # Convert the current time to machine-readable values.
  ($second_now, $minute_now, $hour_now, $day_now, $month_now, $year_now) =
    localtime($Now);

  $month_now += 1;
  $year_now  += 1900;

  # Test which of our several (optionally) dependent, third-party modules are
  # also installed on this Oddmuse Wiki.
  $is_calendar_installed =       defined &draw_month;
  $is_smarttitles_installed =    defined &GetSmartTitles;

  # Declare which actions we provide based on which modules we have available.
  $Action{hibernal} =         \&DoHibernal;
  $Action{hibernal_archive} = \&DoHibernalArchive if $is_calendar_installed;

  # The SmartTitles extension redefines the GetHeader() function. Unfortunately,
  # this extension also redefines that function - so as to obtain the page title
  # and subtitle for the current Hibernal blog page and propagate the page title
  # and subtitle to the next and previous Hibernal blog pages. So, so as to
  # correctly piggyback our redefinition of the GetHeader() function on the
  # back of the SmartTitles refefinition, we forceably reassign that typeglob
  # here, rather than outside a function definition as we'd commonly do.
  *GetHibernalHeaderOld = *GetHeader;
  *GetHeader            = *GetHibernalHeader;

  # Provide default values for comments authorship markup, depending on which
  # other markup modules - if any - are installed.
  if (not defined $HibernalPostCommentsAuthorshipMarkup) {
    if (defined &CreoleAdditionRule) {
      $HibernalPostCommentsAuthorshipMarkup = qq`\n\n"""\n**%s.** %s.\n"""`;
    }
    elsif (defined &CreoleRule) {
      $HibernalPostCommentsAuthorshipMarkup = qq`\n\n|**%s.** %s.|`;
    }
    elsif (defined &UsemodRule) {
      $HibernalPostCommentsAuthorshipMarkup = qq`\n\n||''%s.'' %s.||`;
    }
    elsif (defined &MarkupRule) {
      $HibernalPostCommentsAuthorshipMarkup = qq`\n\n⇒ //**%s.** %s.//`;
    }
    else {
      $HibernalPostCommentsAuthorshipMarkup = qq`\n\n⇒ %s. %s.`;
    }
  }
}

# ....................{ MARKUP                             }....................

=head1 MARKUP

This extension handles page markup resembling:

  <hibernal post_names="$PostNamesRegexp"
            post_bodies="$PostBodiesRegexp"
            posts_start_at="$PostsStartAt"
            posts_per_page="$PostsPerPage"
            posts_ordering="$PostsOrdering">

Or, in its abbreviated form:

  <hibernal "$PostNamesRegexp" "$PostBodiesRegexp"
             $PostsStartAt $PostsPerPage $PostsOrdering>

Or, in its commonly abbreviated form:

  <hibernal "$PostNamesRegexp" $PostsStartAt $PostsPerPage>

Or, in its maximally abbreviated form:

  <hibernal "$PostNamesRegexp">

C<$PostNamesRegexp> is a regular expression matching blog post names for this
blog. Usually, blog post names include the full date on which those blog posts
were posted to that blog; e.g., "Brian_Curry--Blog--2008-04-20". Thus, this
regular expression should include an expression matching such dates. Though not
strictly necessary, most blog frontpages should define this regular expression
in a blog-specific way; e.g., "^Brian_Curry--Blog--/d/d/d/d-/d/d-/d/d". See
L<DATE STANDARDS>, below, for discussion of which date formats this extension
supports. (Hint: it's not all of them! Your dates must adhere to a standard
supported by this extension. Ah, shucks.)

C<$PostBodiesRegexp> is a regular expression further matching blog post body
text. (Defining this regular expression introduces noticeable "slowdown"; as
such, most blogs probably not want to define it. It's quite optional, anyway.)

C<$PostsStartAt> is the index of the first blog post to be displayed on this
blog frontpage. It defaults to "0", the most recent blog post.

C<$PostsPerPage> is the number of blog posts to be displayed per blog page. It
defaults to "8", which is quite reasonable.

C<$PostsOrdering> is a string enumeration, taking one of three possible values:

=over

=item reverse

=item past

=item future

=back

And yes - the above regular expressions must be double-quoted, though the other
attributes need not (but also can) be.

=head2 DATE STANDARDS

hibernal only supports two date-matching regular expressions, at the moment.
hibernal only matches blog posts with page names having dates matched by these
regular expressions. (Blog posts named according to "non-standard" date formats
are ignored, by default, by hibernal.) These are, specifically:

=over

=item '\d\d\d\d-\d\d-\d\d': 4-digit year, 2-digit month, 2-digit day; default.

=item '\d\d-\d\d-\d\d\d\d': 2-digit day, 2-digit month, 4-digit year.

=back

hibernal can be extended to support custom date standards, for blogs with blog
post names not obeying either of the above date standards. To effect this,
simply redefine the C<GetHibernalDaySpecificPostNameRegexp> function.

=cut
push(@MyRules, \&HibernalRule);

# Insist this come before conventional markup rules, so as to avoid conflict
# (e.g., expansion of any '~' characters in your passed regular expressions).
$RuleOrder{\&HibernalRule} = -32;

sub HibernalRule {
  # <hibernal "regexp" 10> includes 10 pages matching that regular expression.
  if ($bol &&
      m~\G(\&lt;hibernal
          (\s+(?:post_names\s*=\s*)?"(.+?)")?
          (\s+(?:post_bodies\s*=\s*)?"(.+?)")?
          (\s+(?:posts_start_at\s*=\s*)?"?(\d+)"?)?
          (\s+(?:posts_per_page\s*=\s*)?"?(\d+)"?)?
          (\s+(?:posts_ordering\s*=\s*)?"?(reverse|past|future)"?)?
          \&gt;[ \t]*\n?)~cgix) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);  # do not cache the prefixing "\G"

    my ($oldpos, $old_) = (pos, $_);
    PrintHibernal($3, $5, $7, $9, $11);
    Clean(AddHtmlEnvironment('p'));  # if dirty block is looked at later, this will disappear
    ($_, pos) = ($old_, $oldpos);    # restore \G (assignment order matters!)

    return '';
  }
  return undef;
}

# ....................{ ACTIONS                            }....................

=head1 ACTIONS

hibernal provides the following actions.

=head2 hibernal

Prints all blog posts (Wiki pages) matching the query parameters passed to this
action. See the C<DoHibernal> function, below.

=head2 hibernal_archive

Prints a calendar-driven archive of all blog posts (Wiki pages) matching the
query parameters passed to this action. See the C<DoHibernalArchive> function,
below.

=head1 FUNCTIONS

hibernal provides the following functions (for implementing those actions).

=cut

# ....................{ CORE REFACTORS                     }....................
*AddComment = *AddHibernalComment;

=head2 AddHibernalComment

Refactors several incongruities in the default C<AddComment> function.

=cut
sub AddHibernalComment {
  my ($comments, $comment) = @_;

  $comment =~ s~\r~~g;     # remove all "\r" (0x0d) characters
  $comment =~ s~\s+$~~gs;  # remove all trailing whitespace

  if ($comment and $comment ne $NewComment) {
    my  $author =   GetParam('username', T('Anonymous'));
    my  $homepage = GetParam('homepage', '');
    if ($homepage) {
      $homepage = "http://$homepage" if not substr($homepage, 0, 7) eq 'http://';
      $author = "[[$homepage|$author]]";
    }
    else {
      $author_page_name = FreeToNormal($author);

      if ($IndexHash{$author_page_name}) {
        $author = $author_page_name eq $author
          ? "[[$author_page_name]]"
          : "[[$author_page_name|$author]]";
      }
    }

    # If at least one comment preceded this comment, separate this comment
    # from that comment with one hard-break.
    if ($comments and $comments =~ m~\S~) {
        $comments .= $HibernalPostCommentsDemarcatorMarkup;
    }

    # Append this comment's author onto this comment.
    $comments .= $comment.
      Tss($HibernalPostCommentsAuthorshipMarkup, $author, TimeToText($Now));
  }

  return $comments;
}

# ....................{ PAGE HEADERS                       }....................
my ($page_title, $page_subtitle);

=head2 GetHibernalHeader

Acquires the title and subtitle from the hibernal front page, for subsequently
passing that title and subtitle to other hibernal and hibernal archive pages.

=cut
sub GetHibernalHeader {
  my $html_header = GetHibernalHeaderOld(@_);

  (undef, $page_title) = $html_header =~ m~\Q<h1>\E(<a.*>)?(.+?)(</a>)?\Q</h1>\E~;
      ($page_subtitle) = $html_header =~ m~\Q<p class="subtitle">\E(.+?)\Q</p>\E~;

  return $html_header;
}

=head2 PrintHibernalHeader

Prints the title and subtitle for other hibernal and hibernal archive pages.
(This does not print the title or subtitle for the hibernal front page, as
that's embedded in the physical markup for that page.)

=cut
sub PrintHibernalHeader {
  my ($page_title_default, $page_subtitle_default, $suffix) = @_;

  $page_title =    GetParam('title',    $default_title);
  $page_subtitle = GetParam('subtitle', $default_subtitle);

  # Avoid tainting the $page_title and $page_subtitle globals with the suffix.
  my ($page_title_suffixed, $page_subtitle_suffixed) =
     ($page_title,          $page_subtitle);

  if ($is_smarttitles_installed and $page_subtitle) {
    $page_subtitle_suffixed .= $suffix;
  }
  else {
    $page_title_suffixed .=    $suffix;
  }

  # Note: we musn't call "GetHibernalHeader", as that could, conceivably, record
  #       the suffix for this page's title or subtitle within the string for
  #       that title or subtitle - which, in recursive turn, would badly cause
  #       that suffix to be appended to the "next" page's title or subtitle,
  #       again. (Good grief, eh? There's little relief, here, for insanity...)
  print GetHibernalHeaderOld(undef, $page_title_suffixed, undef, undef, undef,
                             undef, $page_subtitle_suffixed);
}

# ....................{ HIBERNAL                           }....................

=head2 DoHibernal

Prints all blog posts matched by the passed regular expression and limit bounds.

=cut
sub DoHibernal {
  my $post_name_regexp = GetParam('post_name_regexp', $HibernalDefaultPostNameRegexp);
  my $post_body_regexp = GetParam('post_body_regexp', '');
  my $posts_start_at  =  GetParam('posts_start_at', 0);
  my $posts_per_page  =  GetParam('posts_per_page', $HibernalDefaultPostsPerPage);
  my $posts_ordering  =  GetParam('posts_ordering', '');

  PrintHibernalHeader(T($HibernalDefaultTitle),
                      T($HibernalDefaultSubtitle),
                      Tss($HibernalTitleOrSubtitleSuffix,
                          $posts_start_at,
                          $posts_start_at + $posts_per_page - 1));

  print $q->start_div({-class=> 'content'});
  PrintHibernal($post_name_regexp, $post_body_regexp,
                $posts_start_at,   $posts_per_page, $posts_ordering);
  print $q->end_div();

  PrintFooter();
}

=head2 PrintHibernal

Prints all blog posts for the current set of blog posts, followed by a
set of links for navigating, managing, and otherwise munging those entries.

=cut
sub PrintHibernal {
  return if $HibernalIsCurrentlyPrinting; # avoid infinite loops
  local     $HibernalIsCurrentlyPrinting = 1;

  my ($post_name_regexp, $post_body_regexp,
      $posts_start_at,   $posts_per_page, $posts_ordering) = @_;

  # As this function may, also, be called by HibernalRule(), we must establish
  # some decent defaults.
  $post_name_regexp = $HibernalDefaultPostNameRegexp unless $post_name_regexp;
  $posts_start_at =   0                              unless $posts_start_at;
  $posts_per_page =   $HibernalDefaultPostsPerPage   unless $posts_per_page > 0;
  $posts_per_page =   $HibernalMaximumPostsPerPage   unless $posts_per_page <=
                      $HibernalMaximumPostsPerPage;

  # Implicitly ensure the regular expression also includes comments on all
  # pages matched by this regular expression.
  if ($post_name_regexp !~ m~^\Q^($CommentsPrefix)?\E~ and not
      $post_name_regexp =~ s~^\^~^($CommentsPrefix)?~) {
      $post_name_regexp = "^($CommentsPrefix)?.*$post_name_regexp";
  }

  my @post_names =
    sort SortHibernalPostNames (  # passes, not calls, SortHibernalPostNames()
    grep(/$post_name_regexp/, $post_body_regexp
         ? SearchTitleAndBody($post_body_regexp)
         : AllPagesList()));

  $posts_ordering and OrderHibernalPostNames(\$post_names, $posts_ordering);

  if (defined $post_names[$posts_start_at]) {
        my $posts_end_at;
    # If this Oddmuse Wiki supports comment pages, the determination of how many
    # posts to display becomes a complex to this linear calculation.
    if ($CommentsPrefix) {
      ($posts_start_at, $posts_end_at) = AssayHibernalPostBounds(\@post_names,
       $posts_start_at, $posts_end_at, $posts_per_page);
    }
    # If this Oddmuse Wiki doesn't support comment pages, the determination of
    # how many posts P to display devolves to this linear calculation.
    else {
      $posts_end_at = Max($posts_start_at + $posts_per_page - 1, $#post_names);
    }

    # Calculate this prior to performing array splices.
    my $is_older_posts = $#post_names > $posts_end_at;
    @post_names = @post_names[$posts_start_at..$posts_end_at];  # ...now, do it!

    # Note: we pass the boolean signifying whether there are older posts; since
    # we have truncated the @post_names array, it's no longer sufficient to test
    # that array's length to determine whether there are such posts.
    @post_names and PrintHibernalContent(\@post_names,
      $post_name_regexp, $post_body_regexp,
      $posts_start_at, $posts_end_at, $posts_per_page,
      $posts_ordering, $is_older_posts);
  }
}

=head2 SortHibernalPostNames

Sorts the posts on a hibernal page, according to the Wiki names for those posts
and ensuring that the comment page for a post is sorted after that post.

This function should, probably, be the C<JournalSort>'s default implementation.

=cut
sub SortHibernalPostNames {
  my ($A, $B) = ($a, $b);
  map { s~^$CommentsPrefix~~ or $_ .= 'z' } ($A, $B);
  $B cmp $A;
}

=head2 OrderHibernalPostNames

Orders the posts on a hibernal page, according to whether those posts should be
ordered in date-descending (the default ordering) or date-ascending (the
'future' and 'reverse' orderings).

=cut
sub OrderHibernalPostNames {
  my ($post_names, $posts_ordering) = @_;
  if ($posts_ordering eq 'future' or $posts_ordering eq 'reverse') {
    @$post_names = reverse @$post_names;
  }

  # $a and $b, below, are global variables accessed by SortHibernalPostNames().
  if ($posts_ordering eq 'future' or $posts_ordering eq 'past') {
    $b = defined($Today) ? $Today : CalcDay($Now);

    if ($posts_ordering eq 'future') {
      for (my $i = 0; $i < @$post_names; $i++) {
        $a = $$post_names[$i];
        if (SortHibernalPostNames() == -1) {
          @$post_names = @$post_names[$i..$#$post_names];
          last;
        }
      }
    }
    else {
      for (my $i = 0; $i < @$post_names; $i++) {
        $a = $$post_names[$i];
        if (SortHibernalPostNames() ==  1) {
          @$post_names = @$post_names[$i..$#$post_names];
          last;
        }
      }
    }
  }
}

=head2 AssayHibernalPostBounds

Returns the boundary indices for posts on the current page. These are the
starting and closing indices for posts as dynamically calculated by inspection
of the post names of all potential posts for this page.

Users expect the number of posts per page to be strictly that, and not the
number of posts per page plus the number of posts having comments per page;
however, as the "@post_names" array has posts comingled with comments, the
number of posts per page plus the number of posts having comments per page
is precisely what we get when we test "$#post_names".

A few calculations to correct that, then!

For any given number of posts P, there are at most P*2 comment pages for
those posts (since each post may have at most one comment page). Let us
call the number of comment pages for those posts C. We may determine the
exact value for C, then, by grepping the
"@post_names[$posts_start_at...($posts_per_page*2-1)]" array slice for all
post names beginning with "$CommentsPrefix". Adding P+C provides the total
number of posts and comment pages to be displayed for this hibernal page,
with which we definitively, finally, slice the "@post_names" array.

=cut
sub AssayHibernalPostBounds {
  my ($post_names, $posts_start_at, $posts_end_at, $posts_per_page) = @_;
  my  $posts_sans_comments;
  my  $posts_end_at_max =
    Max($posts_start_at + $posts_per_page*2 - 1, $#$post_names);

  # A bit of an entangling "for" loop, isn't she? "Beware, intrepid code-
  # vagabond: off-one-harshities abound, and eat all who enter here."
  for ($posts_sans_comments = 0,
       $posts_end_at = $posts_start_at - 1,
       $post_index =   $posts_start_at;
       $post_index <= $posts_end_at_max;
       $post_index++, $posts_end_at++) {
    if ($$post_names[$post_index] =~ m~^$CommentsPrefix~) {
      # If the first post is, actually, a comments page (as possibly, though
      # rarely, can occur), faithfully ignore that page by iterating the
      # first post to be displayed one past that comments page (which is
      # guaranteed to be an actual post by the innate constraints of how
      # Oddmuse maintains comments pages). The ignored comments page will,
      # presumably, be displayed upon browsing to the "Older posts..." of
      # the current posts page.
      $posts_start_at++ if $post_index == $posts_start_at;
    }
    # If we've seen as many non-comment posts ($posts_sans_comments) as the
    # user expects ($posts_per_page), then we're done. The index of the post
    # we just looked at ($post_index) specifies the index of the last post
    # to be shown to that user.
    #
    # So. Why don't we just add a "$posts_sans_comments < $posts_per_page"
    # conditional to the above "for" loop? Doesn't the sudden falsity of that
    # conditional imply that we must stop looking and looping? Unfortunately,
    # no. There is a subtle off-by-one trap, here.
    #
    # Consider the edge case in which all posts have comments pages on those
    # posts. Let us say that there are four such posts, altogether: two posts
    # and two comments pages on those pages. Let us also say that the user
    # wants two non-comment posts per page. Then immediately after we look at
    # the second non-comment post, we increment $posts_sans_comments, here,
    # from its former value of 1 to its new value of 2. Thus, the hypothetical
    # conditional described above would cause the loop to stop.
    #
    # That's bad. Why? Because $post_index would have a value of 2, at that
    # point. Posts are indexed from 0. So, that implies that this function
    # would return the range (0, 2) -- or, the first post, its comment page,
    # and the second post. But this fails to include the second post's comment
    # page. We should be returning the range (0, 3), instead. What went wrong?
    # That hypothetical conditional terminated the loop too early.
    #
    # By embedding that conditional here, we ensure that we consider the
    # comments page for the last post. (Wee! Wasn't that gleeful fun?)
    elsif ($posts_sans_comments++ == $posts_per_page) { last; }
  }

  return  ($posts_start_at, $posts_end_at);
}

=head2 AssayHibernalPostBoundsForNewerPosts

Returns the boundary indices for newer posts on the "prior" page. These are the
starting and closing indices for posts as dynamically calculated by inspection
of the post names of all potential posts for this page. Please note: this
function is, at present, only crudely implemented.

Since the index of the post starting the page of newer posts may not,
necessarily, be strictly governed by the linear calculation
"$posts_start_at - $posts_per_page", due to the presence of intervening
comment pages that can, unfortunately, muck with that calculation, we first
attempt to retrieve its proper value from client-provided query parameters.

While this provides an "adequate" solution, it should probably be improved.
I suppose that the only "genuine" solution is, in the absence of a client-
provided query parameter (which we may always assume to be knowledgeably
correct), to dynamically inspect the set of previous posts for a correct
starting index. As hibernal is, already, fairly heavy-weight, we shall wait
on this "improvement," for a bit. It's quite minor in any advent.

O.K.; I've considered this a bit. I can't reuse the above algorithm, though
the algorithm for discerning this, here, can be quite similar. Essentially,
whereas the above algorithm iterates forward from
[$posts_start_at..$posts_start_at+$posts_per_page*2-1], the algorithm here
must iterate backwards from
[$posts_start_at-1..$posts_start_at-$posts_per_page*2]. (Note the slight
"off-by-one"-ness, here.)

=cut
sub AssayHibernalPostBoundsForNewerPosts {
  my ($post_names, $posts_start_at, $posts_end_at, $posts_per_page) = @_;
  my  $posts_start_at_newer = Max(0,
    GetParam('posts_start_at_newer', $posts_start_at - $posts_per_page));
  return    ($posts_start_at_newer,  $posts_start_at - 1);
}

=head2 PrintHibernalContent

Prints blog posts and a set of navigational links after those posts. This
function is separate from C<PrintHibernal>, so as to permit Wiki-specific
redefinition of this function.

=cut
sub PrintHibernalContent {
  my ($post_names, $post_name_regexp, $post_body_regexp,
      $posts_start_at, $posts_end_at, $posts_per_page,
      $posts_ordering, $is_older_posts) = @_;

  # Now save information required for saving the cache of the current page.
  local %Page;
  local $OpenPageName = '';

  print $q->start_div({-class=> 'hibernal'});
  PrintHibernalPosts($post_names);
  PrintHibernalNav  (@_);
  print $q->end_div();
}

=head2 PrintHibernalPosts

Prints all blog posts for the current set of blog posts.

If the SmartTitles extension is installed, this also changes the titles for
blog posts to reflect "#TITLE" or "#SUBTITLE" markup in the content for those
blog posts.

=cut
sub PrintHibernalPosts {
  my $post_names = shift;
  my $lang = GetParam('lang', 0);
  my ($post_title, $post_subtitle);
  my ($prior_post_name, $is_prior_post_commented_on) = ('', 1);

  print $q->start_div({-class=> 'posts'});

  for my $post_name (@$post_names) {
    OpenPage($post_name);
    my @languages = split(/,/, $Page{languages});

    # Skip this post, if this post's language is not this user's language or if
    # marked for deletion but not yet deleted.
    next if
      ($lang and @languages and not grep(/$lang/, @languages)) or
      ($Page{text} =~ m~^$DeletedPage~);

    # If this post is a comment, ...
    if ($post_name =~ m~^$CommentsPrefix~) {
      $is_prior_post_commented_on = 1;

      print
         $q->start_div({-class=> 'post_comments'})
        .$q->div      ({-class=> 'post_comments_header'},
                       GetPageLink($post_name,
                                   Ts($HibernalPostCommentsLinkText)))
        .$q->start_div({-class=> 'post_comments_body hibernal_include'});
      PrintPageHtml();
      print $q->end_div().$q->end_div();
    }
    # If this post is an actual post, ...
    else {
      ($post_title, $post_subtitle) = $is_smarttitles_installed
        ? GetSmartTitles()
        : (NormalToFree($post_name), '');

      PrintHibernalPostCommentsCreateLink($prior_post_name, $is_prior_post_commented_on);
      $is_prior_post_commented_on = '';

      print
         $q->start_div({-class=> 'post'})
        .$q->div({-class=> 'post_header'},
                  $q->h1(GetPageLink($post_name, $post_title))
                 .($post_subtitle
                   ? $q->p({-class=> 'subtitle'}, $post_subtitle) : ''))
        .$q->start_div({-class=> 'post_body hibernal_include'});
      PrintPageHtml();
      print $q->end_div().$q->end_div();
    }

    # Retain the most recent post name, for use immediately below.
    $prior_post_name = $post_name;
  }

  # If the final post had no comments, prints a link for creating the first
  # comments on that post.
  $prior_post_name and
  PrintHibernalPostCommentsCreateLink($prior_post_name, $is_prior_post_commented_on);

  print $q->end_div();
}

=head2 PrintHibernalPostCommentsCreateLink

If the prior post had no comments, prints a link for creating the first
comments on that post.

=cut
sub PrintHibernalPostCommentsCreateLink {
  my ($prior_post_name, $is_prior_post_commented_on) = @_;

  print $q->div({-class=> 'post_comments'},
                $q->div({-class=> 'post_comments_header'},
                        GetPageLink($CommentsPrefix.$prior_post_name,
                                    Ts($HibernalPostCommentsCreateLinkText))))
    if $CommentsPrefix and $prior_post_name and not $is_prior_post_commented_on;
}

=head2 PrintHibernalNav

Prints links for navigating, managing, and otherwise munging blog posts.

If the Calendar extension is installed, this also prints a link to the calendar-
driven archives for these blog posts.

=cut
#FIXME: Per the Oddmuse norm, the link to create a new post should be displayed
# even when the present user is locked from creating such a post; the link's
# text, then, should probably read something resembling
# "Blogger login". Also, per the Google norm, when there are no older or newer
# posts to be linked to, the links to those pages should devolve into greyed-
# out plaintext.
sub PrintHibernalNav {
  my ($post_names, $post_name_regexp, $post_body_regexp,
      $posts_start_at, $posts_end_at, $posts_per_page,
      $posts_ordering, $is_older_posts) = @_;

  my $post_name_regexp_sans_comments =
    GetHibernalCommentlessPostNameRegexp($post_name_regexp);
  my $hibernal_action = "action=hibernal"
    .";post_name_regexp=$post_name_regexp"
    .";post_body_regexp=$post_body_regexp"
    .";posts_ordering=$posts_ordering";
  my $hibernal_archive_action = "action=hibernal_archive"
    .";post_name_regexp=$post_name_regexp_sans_comments";
  my $action_suffix = '';

  # The page title and subtitle were parsed, earlier, by GetHibernalHeader().
  if ($page_title   ) { $action_suffix .= ';title='.   $page_title; }
  if ($page_subtitle) { $action_suffix .= ';subtitle='.$page_subtitle; }

  $hibernal_action .=         $action_suffix;
  $hibernal_archive_action .= $action_suffix;

  my ($older_posts_link_text, $newer_posts_link_text);
  if ($posts_ordering eq 'future' or $posts_ordering eq 'reverse') {
    $newer_posts_link_text = $HibernalOlderPostsLinkText;
    $older_posts_link_text = $HibernalNewerPostsLinkText;
  }
  else {
    $newer_posts_link_text = $HibernalNewerPostsLinkText;
    $older_posts_link_text = $HibernalOlderPostsLinkText;
  }

  print $q->start_div({-class=> 'nav'});

  # If the current user is authorized to edit the page corresponding to today's
  # blog post, display a link to that.
  my $new_post_name =
    GetHibernalDaySpecificPostName($post_name_regexp_sans_comments);
  if (UserCanEdit($new_post_name, 0)) {
    print GetEditLink($new_post_name, T($HibernalNewPostLinkText), undef, T('e'));
  }

  # If there are newer posts to be displayed, display a link to them.
  if (  $posts_start_at > 0) {
    my ($posts_start_at_newer, $posts_end_at_newer) =
      AssayHibernalPostBoundsForNewerPosts($post_names,
        $posts_start_at, $posts_end_at, $posts_per_page);

    print ScriptLink($hibernal_action
                     .";posts_start_at=$posts_start_at_newer"
                     .";posts_per_page=$posts_per_page",
                     T($newer_posts_link_text));
  }

  # If there are older posts to be displayed, display a link to them. (Display
  # this link afore the link to newer posts, as that better coincides with
  # aesthetic expectations - or some such jiggery.)
  #
  # As for why we pass the relatively hacky "posts_start_at_newer" query
  # parameter, see AssayHibernalPostBoundsForNewerPosts() comments.
  if ($is_older_posts) {
    print ScriptLink($hibernal_action
                     .";posts_start_at_newer=$posts_start_at"
                     .";posts_start_at=".($posts_end_at + 1)
                     .";posts_per_page=$posts_per_page",
                     T($older_posts_link_text));
  }

  # If the Calendar extension is also installed, display a link to the archive.
  if ($is_calendar_installed) {
    print ScriptLink($hibernal_archive_action, T($HibernalArchiveLinkText));
  }

  print $q->end_div();
}

# ....................{ HIBERNAL ARCHIVE                   }....................

=head2 DoHibernalArchive

Prints a yearly calendar of all blog posts matched by the passed regular
expression and desired year.

This action requires the third-party Calendar extension.

=cut
sub DoHibernalArchive {
  my $post_name_regexp = GetParam('post_name_regexp', $HibernalDefaultDateRegexp);
  my $year =             GetParam('year',             $year_now);

  PrintHibernalHeader(T($HibernalDefaultArchiveTitle),
                      T($HibernalDefaultArchiveSubtitle),
                      Ts($HibernalArchiveTitleOrSubtitleSuffix, $year));

  print $q->start_div({-class=> 'content'});
  PrintHibernalArchive($post_name_regexp, $year);
  print $q->end_div();

  PrintFooter();
}

=head2 PrintHibernalArchive

This supplants the old C<PrintYearCalendar> function, which provided fewer settings,
less CSS, and, in general, just less.

=cut
sub PrintHibernalArchive {
  my ($post_name_regexp, $year) = @_;

  # Most bloggers are unlikely to want comment pages in their blog archives;
  # consequently, this filters those pages away by preventing this regular
  # expression from matching them.
  $post_name_regexp = GetHibernalCommentlessPostNameRegexp($post_name_regexp);

  print $q->start_div({-class=> 'hibernal_archive cal'});
  PrintHibernalArchiveNav ($post_name_regexp, $year);
  PrintHibernalArchiveYear($post_name_regexp, $year);
  print $q->end_div();
}

sub PrintHibernalArchiveNav {
  my ($post_name_regexp, $year) = @_;
  my @post_names = AllPagesList();

  my %matching_years;
  my $match_year_regexp = $post_name_regexp;
     $match_year_regexp =~ s~(\Q\d\d\d\d\E)~($1)~;

  foreach my $post_name (@post_names) {
    if ($post_name =~ m~$match_year_regexp~) { $matching_years{$1} = 1; }
  }

  print $q->start_div({-class=> 'nav'});
  my $hibernal_archive_action =
    "action=hibernal_archive;post_name_regexp=$post_name_regexp";

  # The page title and subtitle were parsed, earlier, by "GetHibernalHeader".
  if ($page_title   ) { $hibernal_archive_action .= ';title='.   $page_title; }
  if ($page_subtitle) { $hibernal_archive_action .= ';subtitle='.$page_subtitle; }

  foreach my $matching_year (sort keys %matching_years) {
    print ScriptLink($hibernal_archive_action.";year=$matching_year",
                     Ts($HibernalArchiveYearLinkText, $matching_year));
  }

  print $q->end_div();
}

sub PrintHibernalArchiveYear {
  my ($post_name_regexp, $year) = @_;

  print $q->start_div({-class=> 'year'});

  if ($CalAsTable) {
    print '<table><tr>';
    for $month ((1..12)) {
      print '<td>'.GetHibernalArchiveMonth($post_name_regexp, $year, $month).'</td>';

      # Enforce the customary calendar layout of three months per calendar row.
      print '</tr><tr>' if $month == 3 or $month == 6 or $month == 9;
    }
    print '</tr></table>';
  }
  else {
    for $month ((1..12)) {
      print GetHibernalArchiveMonth($post_name_regexp, $year, $month);
    }
  }

  # See documention internal to the GetHibernalArchiveMonth() function, below.
  #
  # Note, this must be nested within the <div class="year">...</div> tag-set.
  # Failure to do this causes borders on that year (and, probably, other CSS
  # flourishes) to deceitfully vanish.
  print $q->div({-class=> 'year_end', -style=> 'clear: left'})
       .$q->end_div();
}

=head2 GetHibernalArchiveMonth

Unfortunately, as the default C<Cal> function is a bit monolithic, this
necessarily reduplicates a large part of that function. Such is life in the code
trenches.

=cut
sub GetHibernalArchiveMonth {
  my ($post_name_regexp, $year, $month) = @_; # example: 2004, 12

  #FIXME: Should use a well-defined Oddmuse CSS error class.
  if ($year < 1) { return $q->p(T('Illegal year value: Use 0001-9999')); }

  my $html_month = draw_month($month, $year).'</div>';

  # Order of substitution is not important, here.
  $html_month =~ s~\s*(\S+) \d\d\d\d\n(.+?\n)~
    GetHibernalArchiveMonthHeader($year, $month, $1, $2)
  ~e;
  $html_month =~ s~( {1,2})(\d{1,2})\b~
    $1.GetHibernalArchiveMonthDay($post_name_regexp, $year, $month, $2)
  ~ge;

  # Float the HTML for each month horizontally past the month preceding it;
  # failure to float months in this manner causes these months to stack
  # vertically, than horizontally. (Vertically stacking months makes the month-
  # driven user interface unusable, effectively.) As such, this function
  # enforces horizontally stacking months as a CSS default via the following
  # inline style. Usually, inline styles are anathema, as they take dictatorial
  # precedence over external stylesheets in CSS's cascade model. (Inline styles
  # cannot be overridden on a per-site basis.) In this instance, given the poor
  # usability of horizontally stacking months, it makes an acceptable exception.
  #
  # Note, also, that floating months requires we "clear" the floating attribute
  # away, afterwards. Failure to do this will propagate that floating attribute
  # to all proceeding block-level elements, which, as expected, unfashionably
  # disrupts the remainder of the CSS-entangled user interface. We thus emit a
  # companion inline style to forcefully "clear" the floating attribute; of
  # necessity, we emit this style following emission of the set of all HTML
  # months, above.
  return $q->div({-class=> 'month', -style=> 'float: left'}, $html_month);
}

sub GetHibernalArchiveMonthHeader {
  my ($year, $month, $month_text, $day_labels) = @_;
  my $date = sprintf('%d-%02d', $year, $month);

  return
     $q->div({-class=> 'month_header'},
             ScriptLink("action=collect;match=%5e$date",
                        "$month_text $year",
                        'local collection month'))
    .$q->start_div({-class=> 'month_body'})
    .$q->span({-class=> 'day_labels'}, $day_labels);
}

sub GetHibernalArchiveMonthDay {
  my ($post_name_regexp, $year, $month, $day) = @_;
  my $class = $day == $day_now && $month == $month_now && $year == $year_now
    ? ' today'
    : ''
    ;

  $post_name_regexp = GetHibernalDaySpecificPostNameRegexp(@_);

  my  @post_name_matches = grep(/$post_name_regexp/, AllPagesList());
  if (@post_name_matches == 0) { # not using GetEditLink because of $class
    return ScriptLink('action=edit;id='.UrlEncode(GetHibernalDaySpecificPostName(@_)),
                      $day, 'edit'.$class);
  }
  elsif (@post_name_matches == 1) { # not using GetPageLink because of $class
    return ScriptLink($post_name_matches[0],
                      $day, 'local exact'.$class);
  }
  else {
    return ScriptLink('action=collect;match='.UrlEncode($post_name_regexp),
                      $day, 'local collection'.$class);
  }
}

# ....................{ UTILITY FUNCTIONS                  }....................

=head2 Tss

Translates a variable number of format variables through one format string.
This function leverages the C<Ts> function; and, thus, could be considered the
expanded, var-arg version of that funcion.

=cut
sub Tss {
  my $format_string = shift;
  my @format_variables = @_;

         $format_string = Ts($format_string, $_) foreach (@format_variables);
  return $format_string;
}

sub Max {
  my ($x, $y) = @_;
  return $x >= $y ? $x : $y;
}

sub GetHibernalDaySpecificPostName {
  my $post_name = GetHibernalDaySpecificPostNameRegexp(@_);

  $post_name =~ s~^\^~~;
  $post_name =~ s~\$$~~;

  return $post_name;
}

sub GetHibernalDaySpecificPostNameRegexp {
  my ($post_name_regexp, $year, $month, $day) = @_;

  $year  = $year_now  unless $year;
  $month = $month_now unless $month;
  $day   = $day_now   unless $day;

  my ($date_regexp) = $post_name_regexp =~ m~(\\d\\d(?:\\d|-)+)~;
  if ($date_regexp) {
    if    ($date_regexp eq '\d\d\d\d-\d\d-\d\d') {
      $post_name_regexp =~
        s~\Q$date_regexp\E~sprintf('%d-%02d-%02d', $year, $month, $day)~e;
    }
    elsif ($date_regexp eq '\d\d-\d\d-\d\d\d\d') {
      $post_name_regexp =~
        s~\Q$date_regexp\E~sprintf('%02d-%02d-%d', $day, $month, $year)~e;
    }
    else { undef $date_regexp; }
  }

  # If this page name does not conform to a hibernal-recognized date standard,
  # we still try to salvage things by "best guessing" it.
  if (not $date_regexp) {
    $post_name_regexp =~ s/\Q\d\d\d\d\E/$year/;
    $post_name_regexp =~ s/\Q\d\d\E/sprintf('%02d', $month)/e;
    $post_name_regexp =~ s/\Q\d\d\E/sprintf('%02d', $day)/e;
  }

  return $post_name_regexp;
}

sub GetHibernalCommentlessPostNameRegexp {
  $post_name_regexp = shift;
  $post_name_regexp =~ s~^\Q^($CommentsPrefix)?\E~^~ if $CommentsPrefix;
  return $post_name_regexp;
}

=head1 EXAMPLES

hibernal builds blogs in a similar way to Oddmuse's own <journal...> markup.
This is pretty simple; so, let's examine a pretty simple example (or three).

=head2 A UNI-BLOGGING EXAMPLE

Suppose there exists a page named "Blog" on some Oddmuse Wiki that contains,
anywhere in its page content, the following markup:

  <hibernal>

Then, the page named "Blog" becomes the front page for this Wiki's blog. It
automatically collects the most recent of all pages whose page names match
the (default) regular expression "\d\d\d\d-\d\d-\d\d" (i.e., consisting of a
4-digit year, 2-digit month, and 2-digit day); and, also, automatically provides
one navigational link for creating a new blog post (corresponding to today),
one navigational link for browsing newer blog posts (if there are newer posts),
one navigational link for browsing older blog posts (if there are older posts),
and one navigational link for browsing the archive of all blog posts via a
(somewhat intuitive) calendar-driven interface.

This is as good - and simple - as it gets. hibernal performs all the "heavy
lifting," behind the code scenes, to glue, link, and conform all of the above
components. (All you have to do is include the <hibernal> markup! There is a
respectable bargain, if ever there was.)

This is the "uni-blogging" scenario. One Oddmuse Wiki collects all matching
blog posts onto one blog front page. Now, let's examine a somewhat less simple
example.

=head2 A MULTI-BLOGGING EXAMPLE

Suppose there exists some page named "User1--Blog" on some Oddmuse Wiki that
contains, anywhere in its page content, the following markup:

  <hibernal "User1--Blog--\d\d\d\d-\d\d-\d\d">

Then suppose there exists another page named "User2--Blog" on that Wiki that
contains, anywhere in its page content, the following similar markup:

  <hibernal "User2--Blog--\d\d\d\d-\d\d-\d\d">

The page named "User1--Blog" becomes the front page for User1's blog; likewise,
the page named "User2--Blog" becomes the front page for User2's blog. (User1
and User2 are, presumably, two users on this Wiki.) The "User1--Blog" page
collects blog posts matching the regular expression for that user's blog
("User1--Blog--\d\d\d\d-\d\d-\d\d"); similarly, the "User2--Blog" page
collects blog posts matching the regular expression for that user's blog
("User2--Blog--\d\d\d\d-\d\d-\d\d"). As above, both front pages automatically
provide navigational links for managing these blogs and blog posts.

And all is well that ends well, and simple.

This is the "multi-blogging" scenario. One Oddmuse Wiki collects all separately
matching blog posts onto two separate blog front pages. Now, let's examine a
somewhat similar example: how, exactly, do users create new blog posts?

=head2 A MULTI-BLOGGING "NEW POSTS" EXAMPLE

Suppose the above two users and corresponding user-specific Wiki pages. Also,
suppose there exist six pages on the Wiki: "User1--Blog--2008-08-08",
"User1--Blog--2007-02-26", "User1--Blog--2000-04-24",
"User2--Blog--2004-05-16", "User2--Blog--2004-05-14", and
"User2--Blog--2004-04-28".

Then, the page named "User1--Blog" shows the "User1--Blog--2008-08-08" page
first (as the first blog post for the blog), "User1--Blog--2007-02-26" second
(as the second-most blog post for the blog), and "User1--Blog--2000-04-24"
list (as the oldest blog post for the blog); and "User2--Blog", similarly, shows
its matching pages as blog posts in chronological order.

To add a new blog post to the front page for User1's blog, that user must:

=over

=item Create a new Wiki page with name following the above naming convention; or

=item Click the "New post" link at the footer of each hibernal page.

=back

And that new post, of hibernal's built-in magic, is automatically collected into
its proper chronological ordering on that front page.

=head1 MULTI-BLOGGING

hibernal, as L<A MULTI-BLOGGING EXAMPLE> (above) demonstrates, has amply capable
support for such multi-blogging. Indeed! This example's infinitely scaleable to
two or more user-defined blogs, as desired by this Wiki. Each user follows some
unique naming convention for blog post pages; and makes:

=over

=item One front page named anything, containing a <hibernal...> expression
      matching other pages following that naming convention, and

=item One or more blog post pages following that convention.

=back

Huzzah!

=head1 MOTIVATION

By default, Oddmuse comes with poor to (frankly) no support for multi-blogging
and merely unstylish, unconfigurable, unsupportable support for uni-blogging.

Oddmuse administrators have "corrected" this, in the darkling past, by:

=over

=item Hackishly isolating each blog on a website onto one distinctly separate
      Oddmuse Wiki installations on that website; by

=item Hacking Wiki functions, non-reusably; and, occasionally, by

=item Hack-installing an incommunicado-ish hodgepodge of unsupported third-party
      Oddmuse Wiki extensions.

Of course, Oddmuse is a Wiki consisting of one Perl script! (This is its
genuis; and its conceit.) It is not, and not intended, to masquerade as a full-
blown Content Management System (CMS) or proper "publishing platform."

Nonetheless, hibernal demonstrates that core Oddmuse functionality can be
improved, substantially, so as to permit one Oddmuse Wiki to mimic conventional
blogging frameworks and, thereby, scaleably host one or more blogs on that Wiki.

Furthermore, hibernal improves support for single-blogging. It redefines most
journal- and calendar-specific functionality with fine-grained, user-settable
CSS, HTML, and RSS customizations, reusability, and code coherence.

=head1 THANKLIST

hibernal is the hive-minded product of "prior art" and artful code. For that,
our dutiful thanks is due: to Alex Schröder (for initializing code-work on the
Journal, RSS, and Calendar extensions), to Charles Mauch (for code-work on the
SmartTitles extension), or to all those hapless, nameless others, whose names,
unremembered, unfurl away. Here's codin' at you, Oddmuse kiddos.

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft 2008 by B.w.Curry <http://www.raiazome.com>.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see L<http://www.gnu.org/licenses/>.

=cut
