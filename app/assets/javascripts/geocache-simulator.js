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

    var authorizationCodeConfirmationCode = {};

    $(document).on('input geocache:touch', '.geocash-simulator #authorization-code-field', function() {
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

                if(authorizationCode in authorizationCodeConfirmationCode) {
                    var confirmationCode = authorizationCodeConfirmationCode[authorizationCode];

                    if(confirmationCode) {
                        $geocashSimulator.find('.step-3 .confirmation-code-message .confirmation-code').text(confirmationCode);
                        $geocashSimulator.find('.step-3 .confirmation-code-message').show();
                    }else{
                        $geocashSimulator.find('.step-3 .confirmation-code-message').hide();
                    }

                    $geocashSimulator.find('.step-3').show();
                }else{
                    if(amount > 0) {
                        $geocashSimulator.find('.step-2.deposit-flow').show();
                        $geocashSimulator.find('.step-2 .deposit-amount').text('$' + amount);
                        $geocashSimulator.find('.step-2 #deposit-actual-amount-field').val('$' + amount).trigger('geocache:touch');
                    }else{
                        $geocashSimulator.find('.step-2.withdraw-flow').show();
                        $geocashSimulator.find('.withdraw-amount').text('$' + -amount);
                    }
                }
            }else{
                $authorizationCodeCard.removeClass('has-warnings').addClass('has-danger');
            }
        }
    });

    $(document).on('input geocache:touch', '.geocash-simulator #deposit-actual-amount-field', function() {
        var $depositActualAmountField = $(this);
        var $card = $depositActualAmountField.parents('.card:first');
        var actualDepositAmount = ~~$depositActualAmountField.val().replace(/^\$/, '');

        $card.removeClass('has-danger has-success');
        
        if(actualDepositAmount > 0 && actualDepositAmount < 100) {
            $card.addClass('has-success');
            $card.find('.deposit-button').prop('disabled', false);
        }else{
            $card.addClass('has-danger');
            $card.find('.deposit-button').prop('disabled', true);
        }
    });

    $(document).on('click', '.geocash-simulator .deposit-button', function() {
        var $geocashSimulator = $('.geocash-simulator');
        var $authorizationCodeField = $geocashSimulator.find('#authorization-code-field');
        var $depositActualAmountField = $geocashSimulator.find('#deposit-actual-amount-field');

        var presharedSecret = $geocashSimulator.attr('data-preshared-secret');
        var authorizationCode = $authorizationCodeField.val();
        var actualDepositAmount = ~~$depositActualAmountField.val().replace(/^\$/, '');

        authorizationCodeConfirmationCode[authorizationCode] = computeCode(actualDepositAmount, 'CONF-FOR-' + authorizationCode + '-' + presharedSecret);
        $authorizationCodeField.trigger('geocache:touch');
    });

    $(document).on('click', '.geocash-simulator .dispense-button', function() {
        var $authorizationCodeField = $('.geocash-simulator #authorization-code-field');
        var authorizationCode = $authorizationCodeField.val();

        authorizationCodeConfirmationCode[authorizationCode] = null; // no need for confirmation on dispense
        $authorizationCodeField.trigger('geocache:touch');
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

    function computeCode(amount, secret) {
        var randomness = computeRandomness();

        return stringify(
            pack(
                [amount > 0 ? 1 : 0, AMOUNT_SIGN_BIT_ENTROPY],
                [Math.abs(amount), AMOUNT_MAGNITUDE_ENTROPY],
                [randomness, RANDOMNESS_ENTROPY],
                [computeDigest(amount, randomness, secret), DIGEST_ENTROPY]
            )
        );
    }

    function computeDigest(amount, randomness, secret) {
        var hex = sha256(amount + '' + randomness + '' + secret);
        var digest = BigInteger.parse(hex, 16);
        var __return = digest.divRem(DIGEST_ENTROPY);
        var remainder = __return[1];

        return remainder.toJSValue();
    }

    function computeRandomness() {
        return ~~(Math.random() * RANDOMNESS_ENTROPY);
    }

    function pack(__parts) {
        __parts = Array.prototype.slice.call(arguments, 0);

        var number = 0;

        for(var index = 0, length = __parts.length, part, value, entropy; index < length; index++) {
            part = __parts[index];
            value = part[0];
            entropy = part[1];

            number = value + number * entropy;
        }

        return number;
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

    function stringify(number) {
        if(number < 0) {
            throw new RangeError();
        }

        var base = CODE_CHARS.length;
        var chars = [];

        for(var index = 0, char; index < 9; index++) {
            if(index === 4) {
                char = CODE_SEPARATOR;
            }else{
                char = CODE_CHARS[number % base];
                number = ~~(number / base);
            }

            chars.push(char);
        }

        if(number !== 0) {
            throw new RangeError();
        }

        return chars.join('');
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