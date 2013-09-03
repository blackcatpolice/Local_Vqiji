// require jquery
// require jquery.widget

(function($, undefined) {
  "use strict";

  $.widget("ui.citySelect", {
    options: {
      current: null
    },
    
    _create: function() {
      this._country = this.element.find("select[data-role=country]");
      this._province = this.element.find("select[data-role=province]");
      this._city = this.element.find("select[data-role=city]");
      
      this._on(this._country, { "change" : this._onCountryChanged });
      this._on(this._province, { "change" : this._onProvinceChanged });

      // 初始化城市信息列表
      if ($.ui.citySelect.cities) {
        this._initSelects();
      } else {
        this._loadCities($.proxy(function(cities) {
          $.ui.citySelect.cities = cities;
          this._initSelects();
        }, this));
      }
    },
    
    _onCountryChanged: function(e) {
      this._fillProvinces(this._selectedCountry().provinces);
      this._fillCities(this._selectedProvince().cities);
    },
    
    _onProvinceChanged: function(e) {
      this._fillCities($(e.target).find(":selected").data("target.citySelect").cities);
    },
    
    _initSelects: function() {
      this._fillCounties($.ui.citySelect.cities);
      this._fillProvinces(this._selectedCountry().provinces);
      this._fillCities(this._selectedProvince().cities);
      if (this.options.current) {
        this.select(this.options.current);
      }
    },
    
    _selectedCountry: function() {
      return this._country.find(":selected").data("target.citySelect");
    },
    
    _selectedProvince: function() {
      return this._province.find(":selected").data("target.citySelect");
    },
    
    _setOptions: function(key, value) {
      if (key === "current") {
        this.select(value);
      }
      this._superApply(key, value);
    },
    
    _destroy: function() {
      this._off(this._country, "change");
      this._off(this._province, "change");
    },
    
    enable: function() {
      this._super();
      this._country.removeAttr("disabled");
      this._province.removeAttr("disabled");
      this._city.removeAttr("disabled");
    },
    
    disable: function() {
      this._country.attr("disabled", "disabled");
      this._province.attr("disabled", "disabled");
      this._city.attr("disabled", "disabled");
      this._super();
    },
    
    reset: function() {
      if (this.options.current) {
        this.select(this.options.current);
      }
      return this;
    },
    
    _loadCities: function(done) {
      var context = this;
      $.ajax("/cities.json", {
        success: done,
        error: function(jqXHR, textStatus, errorThrown ) {
          $.error(errorThrown);
        }
      });
    },
    
    // 添加国家列表
    _fillCounties: function(cities) {
      var context = this;
      this._country.empty();
      $.each(cities, function(i, country) {
        $("<option value='" + country.country + "'>" + country.country + "</option>")
            .data("target.citySelect", country)
            .appendTo(context._country);
      });
    },
    
    // 添加省/州列表
    _fillProvinces: function(provinces) {
      var context = this;
      this._province.empty();
      $.each(provinces, function(i, province) {
        $("<option value=\"" + province.province + "\">" + province.province + "</option>")
          .data("target.citySelect", province)
          .appendTo(context._province);
      });
    },
    
    // 添加城市列表
    _fillCities: function(cities) {
      var context = this;
      this._city.empty();
      $.each(cities, function(i, city) {
        $("<option value='" + city.id + "'>" + city.name + "</option>")
          .data("target.citySelect", city)
          .appendTo(context._city);
      });
    },
    
    select: function(city) {
      if (city) {
        // 反向选中城市
        if (this._country.val() != city.country) {
          // select country
          this._country.val(city.country);
          this._fillProvinces(this._selectedCountry().provinces);
          // select province
          this._province.val(city.province);
          this._fillCities(this._selectedProvince().cities);
        } else if (this._province.val() != city.province) {
          // select province
          this._province.val(city.province);
          this._fillCities(this._selectedProvince().cities);
        }
        // select city
        this._city.val(city.id);
        return this;
      } else {
        if ($.ui.citySelect.cities) {
          return this._city.find(":selected").data("target.citySelect");
        }
        return null;
      }
    }
  });
})(jQuery);
