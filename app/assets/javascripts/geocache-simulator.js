(function ()  {
    Decl({
        matcher: '.geocash-simulator #authorization-code-field',

        matches: function(element) {
            if(!element.__cleave) {
                element.__cleave = new Cleave(element, {
                    blocks: [4, 4],
                    uppercase: true,
                    delimiter: '-'
                });
            }
        },

        unmatches: function(element) {
            if (element.__cleave) {
                element.__cleave.destroy();
                element.__cleave = null;
            }
        }
    });

    $(document).on('input', '.geocash-simulator #authorization-code-field', function() {
        var $authorizationCodeField = $(this);
        var $authorizationCodeCard = $authorizationCodeField.parents('.card:first');
        var $geocashSimulator = $authorizationCodeCard.parents('.geocash-simulator:first');

        var authorizationCode = $authorizationCodeField.val();

        $authorizationCodeCard.removeClass('has-danger has-success');

        $geocashSimulator.find('.step-2, .step-3').hide();

        if(authorizationCode.length === 9) {
            $authorizationCodeCard.addClass('has-warnings');

            var $geocashSimulator = $authorizationCodeField.parents('.geocash-simulator:first');
            var presharedSecret = $geocashSimulator.attr('data-preshared-secret');
            var amount = computeVerifiedAmount(authorizationCode, 'AUTH-' + presharedSecret);

            if(amount) {
                $authorizationCodeCard.removeClass('has-warnings').addClass('has-success');

                if(amount > 0) {
                    $geocashSimulator.find('.step-2.deposit-flow').show();
                    $geocashSimulator.find('.step-2 .deposit-amount').text('$' + amount);
                    $geocashSimulator.find('.step-2 #deposit-actual-amount-field').val('$' + amount);
                }else{
                    $geocashSimulator.find('.step-2.withdraw-flow').show();
                    $geocashSimulator.find('.withdraw-amount').text('$' + -amount);
                }
            }else{
                $authorizationCodeCard.removeClass('has-warnings').addClass('has-danger');
            }
        }
    });

    var CODE_CHARS = [
        '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
        'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S',
        'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    ];
    var CODE_SEPARATOR = '-';
    var MAX_AMOUNT_MAGNITUDE = 100;

    var CODE_ENTROPY = Math.pow(CODE_CHARS.length, 8);

    var AMOUNT_SIGN_BIT_ENTROPY = 2;
    var AMOUNT_MAGNITUDE_ENTROPY = MAX_AMOUNT_MAGNITUDE + 1;
    var AMOUNT_ENTROPY = AMOUNT_SIGN_BIT_ENTROPY * AMOUNT_MAGNITUDE_ENTROPY;

    var RANDOMNESS_ENTROPY = Math.pow(CODE_CHARS.length, 4);

    var DIGEST_ENTROPY = ~~(CODE_ENTROPY / (AMOUNT_ENTROPY * RANDOMNESS_ENTROPY));

    function computeVerifiedAmount(code, secret) {
        var __return = unpack(numberify(code), AMOUNT_SIGN_BIT_ENTROPY, AMOUNT_MAGNITUDE_ENTROPY, RANDOMNESS_ENTROPY, DIGEST_ENTROPY);
        var amount = __return[0] > 0 ? __return[1] : -__return[1];
        var randomness = __return[2];
        var expectedDigest = __return[3];

        if(expectedDigest === computeDigest(amount, randomness, secret)) {
            return amount;
        }else{
            return null;
        }
    }

    function computeDigest(amount, randomness, secret) {
        var hex = sha256(amount + '' + randomness + '' + secret);
        var digest = BigInteger.parse(hex, 16);
        var __return = digest.divRem(DIGEST_ENTROPY);
        var remainder = __return[1];

        return remainder.toJSValue();
    }

    function unpack(number, __entropies) {
        __entropies = Array.prototype.slice.call(arguments, 1);

        var values = [];

        for(var index = __entropies.length - 1, entropy; index >= 0; index--) {
            entropy = __entropies[index];
            values.unshift(number % entropy);
            number = ~~(number / entropy);
        }

        return values;
    }

    function numberify(string) {
        var base = CODE_CHARS.length;
        var number = 0;

        for(var index = string.length - 1, char, value; index >= 0; index--) {
            char = string[index];
            value = CODE_CHARS.indexOf(char);

            if(value !== -1) {
                number *= base;
                number += value;
            }
        }

        return number;
    }
})();