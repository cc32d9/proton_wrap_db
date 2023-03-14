use strict;
use warnings;
use DBD::Pg qw(:pg_types);
use JSON;

my $json = JSON->new->canonical;

my $wrap_contract;

sub wrap_prepare
{
    my $args = shift;

    if( not defined($args->{'wrap_contract'}) )
    {
        print STDERR "Error: wrap_writer.pl requires --parg wrap_contract=XXX\n";
        exit(1);
    }

    $wrap_contract = $args->{'wrap_contract'};

    my $dbh = $main::db->{'dbh'};

    $main::db->{'wrap_current_addresses_ins'} =
        $dbh->prepare('INSERT INTO WRAP_CURRENT_ADDRESSES (idx, account, coin, wallet, address, address_hash) ' .
                      'VALUES (?,?,?,?,?,?)');

    $main::db->{'wrap_current_addresses_del'} =
        $dbh->prepare('DELETE FROM WRAP_CURRENT_ADDRESSES WHERE idx=?');


    $main::db->{'wrap_current_addresses2_ins'} =
        $dbh->prepare('INSERT INTO WRAP_CURRENT_ADDRESSES2 (idx, account, chain, address, address_hash) ' .
                      'VALUES (?,?,?,?,?)');

    $main::db->{'wrap_current_addresses2_del'} =
        $dbh->prepare('DELETE FROM WRAP_CURRENT_ADDRESSES2 WHERE idx=?');


    $main::db->{'wrap_current_wraps_ins'} =
        $dbh->prepare('INSERT INTO WRAP_CURRENT_WRAPS (idx, proton_account, contract, currency, amount, decimals, ' .
                      ' txid, coin, wallet, deposit_address, status, confirmations, finish_txid, wrap_hash) ' .
                      'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)');

    $main::db->{'wrap_current_wraps_del'} =
        $dbh->prepare('DELETE FROM WRAP_CURRENT_WRAPS WHERE idx=?');

    
    $main::db->{'wrap_current_wraps2_ins'} =
        $dbh->prepare('INSERT INTO WRAP_CURRENT_WRAPS2 (idx, proton_account, contract, currency, amount, decimals, ' .
                      ' id, txid, chain, deposit_address, status, confirmations, finish_txid, wrap_hash) ' .
                      'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)');

    $main::db->{'wrap_current_wraps2_del'} =
        $dbh->prepare('DELETE FROM WRAP_CURRENT_WRAPS2 WHERE idx=?');

    
    printf STDERR ("wrap_writer.pl prepared\n");
}



sub wrap_check_kvo
{
    my $kvo = shift;

    if( $kvo->{'code'} eq $wrap_contract )
    {
        return 1;
    }
    return 0;
}


sub wrap_row
{
    my $added = shift;
    my $kvo = shift;
    my $block_num = shift;
    my $block_time = shift;

    if( $kvo->{'code'} eq $wrap_contract and $kvo->{'scope'} eq $wrap_contract )
    {
        my $table = $kvo->{'table'};
        my $v = $kvo->{'value'};

        if( $table eq 'addresses' or $table eq 'addresses2' )
        {
            if( $added )
            {
                $v->{'address_hash'} = lc($v->{'address_hash'});
            }
            
            if( $table eq 'addresses' )
            {
                if( $added )
                {
                    $main::db->{'wrap_current_addresses_ins'}->execute
                        (map {$v->{$_}} ('index', 'account', 'coin', 'wallet', 'address', 'address_hash'));
                }
                else
                {
                    $main::db->{'wrap_current_addresses_del'}->execute($v->{'index'});
                }
            }
            elsif( $table eq 'addresses2' )
            {
                if( $added )
                {
                    $main::db->{'wrap_current_addresses2_ins'}->execute
                        (map {$v->{$_}} ('index', 'account', 'chain', 'address', 'address_hash'));
                }
                else
                {
                    $main::db->{'wrap_current_addresses2_del'}->execute($v->{'index'});
                }
            }
        }
        elsif( $table eq 'wraps' or $table eq 'wraps2' )
        {
            if( $added )
            {
                $v->{'finish_txid'} = lc($v->{'finish_txid'});
                $v->{'wrap_hash'} = lc($v->{'wrap_hash'});                    
                
                $v->{'contract'} = $v->{'balance'}{'contract'};            
                my $bal = $kvo->{'value'}{'balance'}{'quantity'};
                
                if( $bal !~ /^(-?[0-9.]+) ([A-Z]{1,7})$/ )
                {
                    die('Invalid balance quantity: ' . $bal . ', index: ' . $v->{'index'});
                }
                
                my $amount = $1;
                $v->{'currency'} = $2;
                
                my $decimals = 0;
                my $pos = index($amount, '.');
                if( $pos > -1 )
                {
                    $decimals = length($amount) - $pos - 1;
                }
                
                $amount =~ s/\.//;
                $v->{'amount'} = $amount;
                $v->{'decimals'} = $decimals;
            }
            
            if( $table eq 'wraps' )
            {
                if( $added )
                {
                    $main::db->{'wrap_current_wraps_ins'}->execute
                        (map {$v->{$_}} ('index', 'proton_account', 'contract', 'currency', 'amount', 'decimals',
                                         'txid', 'coin', 'wallet', 'deposit_address', 'status', 'confirmations',
                                         'finish_txid', 'wrap_hash'));
                }
                else
                {
                    $main::db->{'wrap_current_wraps_del'}->execute($v->{'index'});
                }
            }
            else
            {
                if( $added )
                {
                    $main::db->{'wrap_current_wraps2_ins'}->execute
                        (map {$v->{$_}} ('index', 'proton_account', 'contract', 'currency', 'amount', 'decimals',
                                         'id', 'txid', 'chain', 'deposit_address', 'status', 'confirmations',
                                         'finish_txid', 'wrap_hash'));
                }
                else
                {
                    $main::db->{'wrap_current_wraps2_del'}->execute($v->{'index'});
                }
            }
        }
    }
}




push(@main::prepare_hooks, \&wrap_prepare);
push(@main::check_kvo_hooks, \&wrap_check_kvo);
push(@main::row_hooks, \&wrap_row);

1;
