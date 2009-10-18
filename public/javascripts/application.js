//计算出入库单产品价格
function set_product_total(obj){
    var obj_id = obj.id 
    var is_amount = obj_id.indexOf("amount") != -1;
    var prefix = is_amount ? obj_id.substring(0, obj_id.length - "amount".length) : obj_id.substring(0, obj_id.length - "unit_price".length);
    
    var amount = $(prefix + "amount");
    var unit_price = $(prefix + "unit_price");
    var total = $(prefix + "total");
    
    total.value = amount.value * unit_price.value;

    set_warehouse_list_total(obj);
}
function set_warehouse_list_total(obj) {
    var warehouse_list_total = 0;
    var elements = $(obj).up("#items").select('input[type=text]');
    for(var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var obj_id = element.id;
        var is_amount = obj_id.indexOf("amount") != -1;
        if(!is_amount) {
            continue;
        }
        if(!$(element).up(".section").visible()) {
            continue;
        }
        var prefix = is_amount ? obj_id.substring(0, obj_id.length - "amount".length) : obj_id.substring(0, obj_id.length - "unit_price".length);

        warehouse_list_total += parseFloat($(prefix + "total").value);
    }
    if(warehouse_list_total) {
        $("warehouse_list_total").value = warehouse_list_total;
    }
    else {
        $("warehouse_list_total").value = 0;
    }
}

function insert_fields(link, method, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + method, "g")
    $(link).up().insert({
        before: content.replace(regexp, new_id)
    });
}
function remove_fields(link) {
    var hidden_field = $(link).previous("input[type=hidden]");
    if (hidden_field) {
        hidden_field.value = '1';
    }
    $(link).up(".section").hide();
}
var crm = {

    EXPANDED      :  "&#9660;",
    COLLAPSED     : "&#9658;",
    request       : null,
    autocompleter : null,
    base_url      : "",

    //----------------------------------------------------------------------------
    date_select_popup: function(id, dropdown_id) {
        $(id).observe("focus", function() {
            if (!$(id).calendar_was_shown) {    // The field recieved initial focus, show the calendar.
                var calendar = new CalendarDateSelect(this, {
                    month_year: "label",
                    year_range: 10,
                    before_close: function() {
                        this.calendar_was_shown = true
                    }
                });
                if (dropdown_id) {
                    calendar.buttons_div.build("span", {
                        innerHTML: " | ",
                        className: "button_seperator"
                    });
                    calendar.buttons_div.build("a", {
                        innerHTML: "Back to List",
                        href: "#",
                        onclick: function() {
                            calendar.close();                   // Hide calendar popup.
                            $(id).hide();                       // Hide date edit field.
                            $(dropdown_id).show();              // Show dropdown.
                            $(dropdown_id).selectedIndex = 0;   // Select first dopdown item.
                            $(id).update("");                   // Reset date field value.
                            return false;
                        }.bindAsEventListener(this)
                    });
                }
            } else {
                $(id).calendar_was_shown = null;  // Focus is back from the closed calendar, make it show up again.
            }
        });

        $(id).observe("blur", function() {
            $(id).calendar_was_shown = null;    // Get the calendar ready if we loose focus.
        });
    },

    //----------------------------------------------------------------------------
    find_form: function(class_name) {
        var forms = $$('form.' + class_name);
        return (forms.length > 0 ? forms[0].id : null);
    },

    //----------------------------------------------------------------------------
    hide_form: function(id) {
        var arrow = $(id + "_arrow") || $("arrow");
        arrow.update(this.COLLAPSED);
        Effect.BlindUp(id, {
            duration: 0.25,
            afterFinish: function() {
                $(id).update("")
            }
        });
    },

    //----------------------------------------------------------------------------
    show_form: function(id) {
        var arrow = $(id + "_arrow") || $("arrow");
        arrow.update(this.EXPANDED);
        Effect.BlindDown(id, {
            duration: 0.25,
            afterFinish: function() {
                var input = $(id).down("input[type=text]");
                if (input) input.focus();
            }
        });
    },

    //----------------------------------------------------------------------------
    flip_form: function(id) {
        if ($(id)) {
            if (Element.visible(id)) {
                this.hide_form(id);
            } else {
                this.show_form(id);
            }
        }
    },

    //----------------------------------------------------------------------------
    set_title: function(id, caption) {
        var title = $(id + "_title") || $("title");
        if (typeof(caption) == "undefined") {
            var words = id.split("_");
            if (words.length == 1) {
                caption = id.capitalize();
            } else {
                caption = words[0].capitalize() + " " + words[1].capitalize();
            }
        }
        title.update(caption);
    },

    //----------------------------------------------------------------------------
    highlight_off: function(id) {
        $(id).onmouseover = $(id).onmouseout = null;
        $(id).style.background = "white";
    },

    //----------------------------------------------------------------------------
    focus_on_first_field: function() {
        if ($$("form") != "") {
            var first_element = $$("form")[0].findFirstElement();
            if (first_element) {
                first_element.focus();
                first_element.value = first_element.value;
            }
        } else if ($("query")) {
            $("query").focus();
        }
    },

    // Hide accounts dropdown and show create new account edit field instead.
    //----------------------------------------------------------------------------
    create_customer: function(and_focus) {
        $("customer_selector").update(" (创建新的客户 or <a href='#' onclick='crm.select_customer(1); return false;'>选择已有客户</a>):");
        $("customer_id").hide();
        $("customer_id").disable();
        $("customer_name").enable();
        $("customer_name").clear();
        $("customer_name").show();
        if (and_focus) {
            $("customer_name").focus();
        }
    },

    // Hide create account edit field and show accounts dropdown instead.
    //----------------------------------------------------------------------------
    select_customer: function(and_focus) {
        $("customer_selector").update(" (<a href='#' onclick='crm.create_customer(1); return false;'>创建新的客户</a> or 选择已有客户):");
        $("customer_name").hide();
        $("customer_name").disable();
        $("customer_id").enable();
        $("customer_id").show();
        if (and_focus) {
            $("customer_id").focus();
        }
    },

    // Show accounts dropdown and disable it to prevent changing the account.
    //----------------------------------------------------------------------------
    select_existing_customer: function() {
        $("customer_selector").update(":");
        $("custoer_name").hide();
        $("customer_name").disable();
        $("customer_id").disable();
        $("customer_id").show();
    },

    //----------------------------------------------------------------------------
    create_or_select_customer: function(selector) {
        if (selector !== true && selector > 0) {
            this.select_existing_customer(); // disabled accounts dropdown
        } else if (selector) {
            this.create_customer();          // create account edit field
        } else {
            this.select_customer();          // accounts dropdown
        }
    },

    //----------------------------------------------------------------------------
    flip_calendar: function(value) {
        if (value == "specific_time") {
            $("task_bucket").toggle(); // Hide dropdown.
            $("task_calendar").toggle();    // Show editable date field.
            $("task_calendar").focus();     // Focus to invoke calendar popup.
        }
    },

    //----------------------------------------------------------------------------
    flip_campaign_permissions: function(value) {
        if (value) {
            $("lead_access_campaign").enable();
            $("lead_access_campaign").checked = 1;
            $("copy_permissions").style.color = "#3f3f3f";
        } else {
            $("lead_access_campaign").disable();
            $("copy_permissions").style.color = "grey";
            $("lead_access_private").checked = 1;
        }
    },

    //----------------------------------------------------------------------------
    flip_subtitle: function(el) {
        var arrow = Element.down(el, "small");
        var intro = Element.down(Element.next(Element.up(el)), "small");
        var section = Element.down(Element.next(Element.up(el)), "div");

        if (Element.visible(section)) {
            arrow.update(this.COLLAPSED);
            Effect.toggle(section, 'slide', {
                duration: 0.25,
                afterFinish: function() {
                    intro.toggle();
                }
            });
        } else {
            arrow.update(this.EXPANDED);
            Effect.toggle(section, 'slide', {
                duration: 0.25,
                beforeStart: function() {
                    intro.toggle();
                }
            });
        }
    },

    //----------------------------------------------------------------------------
    reschedule_task: function(id, bucket) {
        $("task_bucket").value = bucket;
        $("edit_task_" + id).onsubmit();
    },

    //----------------------------------------------------------------------------
    flick: function(element, action) {
        if ($(element)) {
            switch(action) {
                case "show":   $(element).show();     break;
                case "hide":   $(element).hide();     break;
                case "clear":  $(element).update(""); break;
                case "remove": $(element).remove();   break;
                case "toggle": $(element).toggle();   break;
            }
        }
    },

    //----------------------------------------------------------------------------
    flash: function(type, sticky) {
        $("flash").hide();
        if (type == "warning" || type == "error") {
            $("flash").className = "flash_warning";
        } else {
            $("flash").className = "flash_notice";
        }
        Effect.Appear("flash", {
            duration: 0.5
        });
        if (!sticky) {
            setTimeout("Effect.Fade('flash')", 3000);
        }
    },

    //----------------------------------------------------------------------------
    search: function(query, controller) {
        if (!this.request) {
            var list = controller;          // ex. "users"
            if (list.indexOf("/") >= 0) {   // ex. "admin/users"
                list = list.split("/")[1];
            }
            $("loading").show();
            $(list).setStyle({
                opacity: 0.4
            });
            new Ajax.Request(this.base_url + "/" + controller + "/search", {
                method     : "get",
                parameters : {
                    query : query
                },
                onSuccess  : function() {
                    $("loading").hide();
                    $(list).setStyle({
                        opacity: 1
                    });
                },
                onComplete : (function() {
                    this.request = null;
                }).bind(this)
            });
        }
    },

    //----------------------------------------------------------------------------
    jumper: function(controller, controller_chinese_name) {
        var name = controller.capitalize();
        $$("#jumpbox a").each(function(link) {
            if (link.innerHTML == controller_chinese_name) {
                link.addClassName("selected");
            } else {
                link.removeClassName("selected");
            }
        });
        this.auto_complete(controller, true);
    },

    //----------------------------------------------------------------------------
    auto_complete: function(controller, focus) {
        if (this.autocompleter) {
            Event.stopObserving(this.autocompleter.element);
            delete this.autocompleter;
        }
        this.autocompleter = new Ajax.Autocompleter("auto_complete_query", "auto_complete_dropdown", this.base_url + "/" + controller + "/auto_complete", {
            frequency: 0.25,
            afterUpdateElement: function(text, el) {
                if (el.id) {  // found: redirect to #show
                    window.location.href = this.base_url + "/" + controller + "/" + escape(el.id);
                } else {      // not found: refresh current page
                    $("auto_complete_query").value = "";
                    window.location.href = window.location.href;
                }
            }.bind(this)    // binding for this.base_url
        });
        $("auto_complete_dropdown").update("");
        $("auto_complete_query").value = "";
        if (focus) {
            $("auto_complete_query").focus();
        }
    }
}

// Note: observing "dom:loaded" is supposedly faster that "window.onload" since
// it will fire immediately after the HTML document is fully loaded, but before
// images on the page are fully loaded.

// Event.observe(window, "load", function() { crm.focus_on_first_field() })
document.observe("dom:loaded", function() { 
    crm.focus_on_first_field()
});
