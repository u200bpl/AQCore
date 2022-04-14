AQ.Phone.Settings = {};
AQ.Phone.Settings.Background = "default-AQCore";
AQ.Phone.Settings.OpenedTab = null;
AQ.Phone.Settings.Backgrounds = {
    'default-AQCore': {
        label: "Standard AQCore"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        AQ.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        AQ.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "profilepicture") {
        AQ.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        AQ.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        AQ.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", AQ.Phone.Data.AnonymousCall);

        if (!AQ.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Off');
        } else {
            $("#numberrecognition > p").html('On');
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = AQ.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        AQ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", AQ.Phone.Settings.Backgrounds[AQ.Phone.Settings.Background].label+" is set!")
        AQ.Phone.Animations.TopSlideUp(".settings-"+AQ.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+AQ.Phone.Settings.Background+".png')"})
    } else {
        AQ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set!")
        AQ.Phone.Animations.TopSlideUp(".settings-"+AQ.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+AQ.Phone.Settings.Background+"')"});
    }

    $.post('https://aq-phone/SetBackground', JSON.stringify({
        background: AQ.Phone.Settings.Background,
    }))
});

AQ.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        AQ.Phone.Settings.Background = MetaData.background;
    } else {
        AQ.Phone.Settings.Background = "default-AQCore";
    }

    var hasCustomBackground = AQ.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+AQ.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+AQ.Phone.Settings.Background+"')"});
    }

    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    AQ.Phone.Animations.TopSlideUp(".settings-"+AQ.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

AQ.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(AQ.Phone.Settings.Backgrounds, function(i, background){
        if (AQ.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            AQ.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            AQ.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();

    AQ.Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    AQ.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    AQ.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = AQ.Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        AQ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standard avatar set!")
        AQ.Phone.Animations.TopSlideUp(".settings-"+AQ.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        AQ.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal avatar set!")
        AQ.Phone.Animations.TopSlideUp(".settings-"+AQ.Phone.Settings.OpenedTab+"-tab", 200, -100);
        console.log(ProfilePicture)
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
    }
    $.post('https://aq-phone/UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    AQ.Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    AQ.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            AQ.Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            AQ.Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    }
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    AQ.Phone.Animations.TopSlideUp(".settings-"+AQ.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    AQ.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});
