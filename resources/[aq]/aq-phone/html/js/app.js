AQ = {}
AQ.Phone = {}
AQ.Screen = {}
AQ.Phone.Functions = {}
AQ.Phone.Animations = {}
AQ.Phone.Notifications = {}
AQ.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

AQ.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

AQ.Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

var CanOpenApp = true;

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && AQ.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

AQ.Phone.Functions.SetupApplications = function(data) {
    AQ.Phone.Data.Applications = data.applications;

    var i;
    for (i = 1; i <= AQ.Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, AQ.Phone.Data.PlayerJob.name)

        if ((!app.job || app.job === AQ.Phone.Data.PlayerJob.name) && !blockedapp) {
            $(applicationSlot).css({"background-color":app.color});
            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            if (app.app == "meos") {
                icon = '<img src="./img/politie.png" class="police-icon">';
            }
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

AQ.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

AQ.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (AQ.Phone.Data.currentApplication == null) {
                AQ.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                AQ.Phone.Functions.ToggleApp(PressedApplication, "block");
                
                if (AQ.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    AQ.Phone.Functions.HeaderTextColor("black", 300);
                }
    
                AQ.Phone.Data.currentApplication = PressedApplication;
    
                if (PressedApplication == "settings") {
                    $("#myPhoneNumber").text(AQ.Phone.Data.PlayerData.charinfo.phone);
                    $("#mySerialNumber").text("aq-" + AQ.Phone.Data.PlayerData.metadata["phonedata"].SerialNumber);
                } else if (PressedApplication == "twitter") {
                    $.post('https://aq-phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                        AQ.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
                    })
                    $.post('https://aq-phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                        AQ.Phone.Notifications.LoadHashtags(Hashtags)
                    })
                    if (AQ.Phone.Data.IsOpen) {
                        $.post('https://aq-phone/GetTweets', JSON.stringify({}), function(Tweets){
                            AQ.Phone.Notifications.LoadTweets(Tweets);
                        });
                    }
                } else if (PressedApplication == "bank") {
                    AQ.Phone.Functions.DoBankOpen();
                    $.post('https://aq-phone/GetBankContacts', JSON.stringify({}), function(contacts){
                        AQ.Phone.Functions.LoadContactsWithNumber(contacts);
                    });
                    $.post('https://aq-phone/GetInvoices', JSON.stringify({}), function(invoices){
                        AQ.Phone.Functions.LoadBankInvoices(invoices);
                    });
                } else if (PressedApplication == "whatsapp") {
                    $.post('https://aq-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
                        AQ.Phone.Functions.LoadWhatsappChats(chats);
                    });
                } else if (PressedApplication == "phone") {
                    $.post('https://aq-phone/GetMissedCalls', JSON.stringify({}), function(recent){
                        AQ.Phone.Functions.SetupRecentCalls(recent);
                    });
                    $.post('https://aq-phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
                        AQ.Phone.Functions.SetupSuggestedContacts(suggested);
                    });
                    $.post('https://aq-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "phone"
                    }));
                } else if (PressedApplication == "mail") {
                    $.post('https://aq-phone/GetMails', JSON.stringify({}), function(mails){
                        AQ.Phone.Functions.SetupMails(mails);
                    });
                    $.post('https://aq-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                } else if (PressedApplication == "advert") {
                    $.post('https://aq-phone/LoadAdverts', JSON.stringify({}), function(Adverts){
                        AQ.Phone.Functions.RefreshAdverts(Adverts);
                    })
                } else if (PressedApplication == "garage") {
                    $.post('https://aq-phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                        SetupGarageVehicles(Vehicles);
                    })
                } else if (PressedApplication == "crypto") {
                    $.post('https://aq-phone/GetCryptoData', JSON.stringify({
                        crypto: "aqbit",
                    }), function(CryptoData){
                        SetupCryptoData(CryptoData);
                    })

                    $.post('https://aq-phone/GetCryptoTransactions', JSON.stringify({}), function(data){
                        RefreshCryptoTransactions(data);
                    })
                } else if (PressedApplication == "racing") {
                    $.post('https://aq-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                } else if (PressedApplication == "houses") {
                    $.post('https://aq-phone/GetPlayerHouses', JSON.stringify({}), function(Houses){
                        SetupPlayerHouses(Houses);
                    });
                    $.post('https://aq-phone/GetPlayerKeys', JSON.stringify({}), function(Keys){
                        $(".house-app-mykeys-container").html("");
                        if (Keys.length > 0) {
                            $.each(Keys, function(i, key){
                                var elem = '<div class="mykeys-key" id="keyid-'+i+'"> <span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Click to set GPS</span> </div>';

                                $(".house-app-mykeys-container").append(elem);
                                $("#keyid-"+i).data('KeyData', key);
                            });
                        }
                    });
                } else if (PressedApplication == "meos") {
                    SetupMeosHome();
                } else if (PressedApplication == "lawyers") {
                    $.post('https://aq-phone/GetCurrentLawyers', JSON.stringify({}), function(data){
                        SetupLawyers(data);
                    });
                } else if (PressedApplication == "store") {
                    $.post('https://aq-phone/SetupStoreApps', JSON.stringify({}), function(data){
                        SetupAppstore(data); 
                    });
                } else if (PressedApplication == "trucker") {
                    $.post('https://aq-phone/GetTruckerData', JSON.stringify({}), function(data){
                        SetupTruckerInfo(data);
                    });
                }
            }
        }
    } else {
        AQ.Phone.Notifications.Add("fas fa-exclamation-circle", "System", AQ.Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('https://aq-phone/SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (AQ.Phone.Data.currentApplication === null) {
        AQ.Phone.Functions.Close();
    } else {
        AQ.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        AQ.Phone.Animations.TopSlideUp('.'+AQ.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            AQ.Phone.Functions.ToggleApp(AQ.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        AQ.Phone.Functions.HeaderTextColor("white", 300);

        if (AQ.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (AQ.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});
    
                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');
    
                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');
    
                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (AQ.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("noodknop");
                $(".meos-recent-alert").css({"background-color":"#004682"}); 
            }, 400)
        }

        AQ.Phone.Data.currentApplication = null;
    }
});

AQ.Phone.Functions.Open = function(data) {
    AQ.Phone.Animations.BottomSlideUp('.container', 300, 0);
    AQ.Phone.Notifications.LoadTweets(data.Tweets);
    AQ.Phone.Data.IsOpen = true;
}

AQ.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

AQ.Phone.Functions.Close = function() {

    if (AQ.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            AQ.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            AQ.Phone.Animations.TopSlideUp('.'+AQ.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            AQ.Phone.Functions.HeaderTextColor("white", 300);
    
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            AQ.Phone.Data.currentApplication = null;
        }, 500)
    } else if (AQ.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("noodknop");
        $(".meos-recent-alert").css({"background-color":"#004682"}); 
    }

    AQ.Phone.Animations.BottomSlideDown('.container', 300, -70);
    $.post('https://aq-phone/Close');
    AQ.Phone.Data.IsOpen = false;
}

AQ.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

AQ.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

AQ.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

AQ.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

AQ.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

AQ.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('https://aq-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (AQ.Phone.Notifications.Timeout == undefined || AQ.Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!AQ.Phone.Data.IsOpen) {
                    AQ.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                AQ.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                if (icon !== "politie") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (AQ.Phone.Notifications.Timeout !== undefined || AQ.Phone.Notifications.Timeout !== null) {
                    clearTimeout(AQ.Phone.Notifications.Timeout);
                }
                AQ.Phone.Notifications.Timeout = setTimeout(function(){
                    AQ.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!AQ.Phone.Data.IsOpen) {
                        AQ.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    AQ.Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!AQ.Phone.Data.IsOpen) {
                    AQ.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (AQ.Phone.Notifications.Timeout !== undefined || AQ.Phone.Notifications.Timeout !== null) {
                    clearTimeout(AQ.Phone.Notifications.Timeout);
                }
                AQ.Phone.Notifications.Timeout = setTimeout(function(){
                    AQ.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!AQ.Phone.Data.IsOpen) {
                        AQ.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    AQ.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

AQ.Phone.Functions.LoadPhoneData = function(data) {
    AQ.Phone.Data.PlayerData = data.PlayerData;
    AQ.Phone.Data.PlayerJob = data.PlayerJob;
    AQ.Phone.Data.MetaData = data.PhoneData.MetaData;
    AQ.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    AQ.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    AQ.Phone.Functions.SetupApplications(data);
    // console.log("Phone succesfully loaded!");
}

AQ.Phone.Functions.UpdateTime = function(data) {    
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html(MessageTime + " <span style='font-size: 1.1vh;'>" + data.InGameTime.hour + ":" + data.InGameTime.minute + "</span>");
}

var NotificationTimeout = null;

AQ.Screen.Notification = function(title, content, icon, timeout, color) {
    $.post('https://aq-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (color != null && color != undefined) {
                $(".screen-notifications-container").css({"background-color":color});
            }
            $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
            $(".screen-notification-title").text(title);
            $(".screen-notification-content").text(content);
            $(".screen-notifications-container").css({'display':'block'}).animate({
                right: 5+"vh",
            }, 200);
        
            if (NotificationTimeout != null) {
                clearTimeout(NotificationTimeout);
            }
        
            NotificationTimeout = setTimeout(function(){
                $(".screen-notifications-container").animate({
                    right: -35+"vh",
                }, 200, function(){
                    $(".screen-notifications-container").css({'display':'none'});
                });
                NotificationTimeout = null;
            }, timeout);
        }
    });
}

// AQ.Screen.Notification("Nieuwe Tweet", "Dit is een test tweet like #YOLO", "fab fa-twitter", 4000);

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                AQ.Phone.Functions.Open(event.data);
                AQ.Phone.Functions.SetupAppWarnings(event.data.AppData);
                AQ.Phone.Functions.SetupCurrentCall(event.data.CallData);
                AQ.Phone.Data.IsOpen = true;
                AQ.Phone.Data.PlayerData = event.data.PlayerData;
                break;
            // case "LoadPhoneApplications":
            //     AQ.Phone.Functions.SetupApplications(event.data);
            //     break;
            case "LoadPhoneData":
                AQ.Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                AQ.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                AQ.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
                break;
            case "PhoneNotification":
                AQ.Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout);
                break;
            case "RefreshAppAlerts":
                AQ.Phone.Functions.SetupAppWarnings(event.data.AppData);                
                break;
            case "UpdateMentionedTweets":
                AQ.Phone.Notifications.LoadMentionedTweets(event.data.Tweets);                
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html("&#36; "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (AQ.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        console.log('Chat reloaded')
                        AQ.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        console.log('Chats reloaded')
                        AQ.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                AQ.Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "RefreshWhatsappAlerts":
                AQ.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('https://aq-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('https://aq-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                AQ.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                AQ.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);

                if (!AQ.Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }

                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                AQ.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    AQ.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                AQ.Phone.Functions.HeaderTextColor("white", 300);
    
                AQ.Phone.Data.CallActive = false;
                AQ.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                AQ.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                AQ.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (AQ.Phone.Data.currentApplication == "advert") {
                    AQ.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                AQ.Phone.Data.PlayerJob = event.data.JobData;
                AQ.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('https://aq-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                AQ.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
        }
    })
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
            AQ.Phone.Functions.Close();
            break;
    }
});

// AQ.Phone.Functions.Open();