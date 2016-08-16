# Copyright (C) 2008 Eric Hsu <apricotan@gmail.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

AddModuleDescription('cart.pl', 'Cart Extension');

our ($q, %Action, $UserGotoBar, $CookieName);
our ($CartPic, $CartName, %Cart, $ShowCart, @CartOrdered);
my $LOADED_CART_JS;

# ============
# = cart-bfc =
# ============

# This is a simple shopping cart for pages!
# Requires searchpaged-bfc.pl.

# We make a checkbox that onChange, uses Yahoo! UI Cookie 2.6 (note we need 2.6!) routines to set a subcookie.
# We have the cookie "$CartName" (by default $Cookiename . "Cart")
# which holds the actual cart and is managed almost entirely
# in client-side javascript. That means the checkboxes directly control the cookie.

# If you want a little picture of a cart, you can set the URL at $CartPic.

# InitCart loads the cookie values into %Cart. $Cart->{$pagename}=1 if it's in the cart.
# In theory cookies are capped at 4K. Our page names are capped around 90ish chars. That leaves room for 40 maximal names in the cart. Probably enough.

# We'll need the cookie values for
# action=cart;subaction=show; along with other future subactions (download in latex, bibtex)
# we'll feed this display to a variant of search display.
# I'll have to check oddmuse.pl.

# load Yahoo UI code bit to manage subcookies.

$Action{cart} = \&DoCart;

sub DoCart {
  # foreach $key (keys %Cart) {
  # 	push @cart, $key  if ($Cart{"$key"});
  # }
  DoSearch(\@CartOrdered);
}

$UserGotoBar .= '<a href="?action=cart;cache=0">View Cart</a>';

# Manage Cart Routines

#push @MyPrintSearchResultsPrefix, \&PrintCheckboxTableStart;
#push @MyPrintSearchResultsSuffix, \&PrintCheckboxTableEnd;

# I can't hack into Init, so let's tap into InitCookie.
# We also tap into Cookie() to arrange writing out our cleaned up Cart.

*OldInitCookie = *InitCookie;
*InitCookie = *InitCookieAndCart;

# To get a checkbox in the titles of pages, we patch GetHeader.
*OldGetHeader = *GetHeader;
*GetHeader = *GetHeaderAndCart;

sub InitCookieAndCart {
  OldInitCookie();
  InitCart();
}

sub GetHeaderAndCart {
  my ($id, $title, $oldId, $nocache, $status) = @_;
  my $result = OldGetHeader(@_);

  return ($result) unless ($id);

  my $checkbox = MakeCheckbox($id);
  $checkbox = qq(<span class="cart-checkbox" style="float:right">$checkbox</span>);

  $result =~ s/(<\/h1>)/$checkbox$1/;

  return ($result);
}


# We load the contents of our Cart cookie into the global %Cart and @CartOrdered
sub InitCart {
  $CartName = $CookieName . "Cart" unless (defined ($CartName) );
  my @pairs;

  %Cart = ();
  @CartOrdered = ();

  if ($q->cookie($CartName)) {
    # @pairs = split(/&/, $q->cookie($CartName));
    @pairs =  $q->cookie($CartName);
    foreach my $pair (@pairs) {
      # my $encodedequals = UrlEncode("=");
      my ($name, $val)= split(/\=/, $pair);
      $Cart{"$name"}=$val;
      push @CartOrdered, $name;
    }
  }
}

sub PrintCheckboxTableStart {
  my ($name, $regex, $text, $type) = @_;
  my $html;

  $html .= "<table><tr>";
  my $checkbox = MakeCheckbox(@_);
  $html .= qq(<td valign=top>$checkbox</td>);
  $html .= "<td valign=top>";
  print $html;
}

sub PrintCheckboxTableEnd {
  my ($name, $regex, $text, $type) = @_;
  my $html;

  $html .= "</td>";
  $html .= "</tr></table>";

  print $html;
}


sub MakeCheckbox {
  my ($name, $regex, $text, $type) = @_;
  my $html;

  return unless ($ShowCart);
  unless ($LOADED_CART_JS) {
    $html .= '<script type="text/javascript" src="http://yui.yahooapis.com/combo?2.7.0/build/yahoo/yahoo-min.js&2.7.0/build/cookie/cookie-min.js&2.7.0/build/event/event-min.js"></script>';
    $LOADED_CART_JS=1;
  }

  my $selected = qq(checked="yes") if ($Cart{"$name"});

	$html .=<<HTMLEND;
	$CartPic<input type="checkbox" value="cart" id="$name-set" title="Add To Cart" $selected/> <br>
	<script type="text/javascript">
	(function(){
	    YAHOO.util.Event.on("$name-set", "change", function(){
	        var value = YAHOO.util.Cookie.getSub("$CartName", "$name");
	        if (value == 1 ) { YAHOO.util.Cookie.removeSub("$CartName", "$name"); }
	        else { YAHOO.util.Cookie.setSub("$CartName", "$name", 1 ); }
	    });
	})();
	</script>
HTMLEND

  return $html unless ($q->param('action') eq 'edit' || $q->param('Preview'));
  # no checkboxes for edit pages.
  return;
}

__END__

=
(0.7) Load JS libraries on first checkbox (so won't load if we are editing).
(0.6) Changed the JS source to be Yahoo's CDN.
(0.51) Use CSS class cart-checkbox for the cart checkbox!  That way, we can remove them for printouts, for instance.
(0.5) Our hack of cookies was not working cross-platform. We have a mismatch because our attempts to send out a cookie from oddmuse were getting the contents encoded and unreadable for the YUI routines.  Instead,we will use removeSub to avoid ever having to send the cookie back from our server!
(0.4) Now every page title has a checkbox floated to the right, which controls the cart status.
(0.3) Allow cart editing from cart display. Currently, doesn't seem to affect the cart.
(0.2) Cart now displays.
(0.1) Cart is now persistent and is edited by the checkboxes.
