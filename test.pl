use Crypt::CBC;
use Crypt::Cipher::AES;
use MIME::Base64;
 
my $key = 'my secret key'; # length has to be valid key size for this cipher
my $cipher = Crypt::CBC->new( -cipher=>'Cipher::AES', -key=>$key );
my $ciphertext = $cipher->encrypt("secret data");
my $code = encode_base64($ciphertext);
chomp $code;
print "$code\n";

my $cipher2 = Crypt::CBC->new( -cipher=>'Cipher::AES', -key=>$key );
my $plaintext = $cipher2->decrypt(decode_base64($code));
print $plaintext . "\n";

use Crypt::Random qw( makerandom );
my $r = join('', map { sprintf("\\x%x", makerandom( Size => 8, Uniform => 1, Strength => 1 )) } 1..16);
printf "$r\n";
