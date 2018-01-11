// Generated by CoffeeScript 1.12.6
(function() {
  this.SingeGenreArtistsCrawler = (function() {
    var DEBUG_MODE, DEFAULT_TIMEOUT, FIRST_LOAD_TIMEOUT, GENRE_SHORTCODE, GENRE_URL_TEMPLATE, START_SHORTCODE;

    GENRE_URL_TEMPLATE = "https://www.metal-archives.com/browse/ajax-genre/g/${genre}/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=${start}&iDisplayLength=500&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false&_=1497809147851";

    GENRE_SHORTCODE = "${genre}";

    START_SHORTCODE = "${start}";

    FIRST_LOAD_TIMEOUT = 2000;

    DEFAULT_TIMEOUT = 750;

    DEBUG_MODE = false;

    function SingeGenreArtistsCrawler(genre1, parentContext) {
      this.genre = genre1;
      this.parentContext = parentContext;
      console.log("Started crawler for genre " + genre + "...");
      this.genreArtists = [];
      this.maxPages = 3;
      this.currentPage = 1;
    }

    SingeGenreArtistsCrawler.prototype.crawl = function() {
      return this._loadByGenre(this.genre);
    };

    SingeGenreArtistsCrawler.prototype._loadByGenre = function(genre) {
      var isFirstLoad, onTheFlyData, searchUrl, self, setMaxPages, timeoutValue;
      isFirstLoad = this.currentPage === 1;
      timeoutValue = isFirstLoad ? FIRST_LOAD_TIMEOUT : DEFAULT_TIMEOUT;
      if (DEBUG_MODE) {
        setMaxPages = false;
      } else {
        setMaxPages = isFirstLoad;
      }
      if (this.currentPage === this.maxPages) {
        self = this;
        setTimeout(function() {
          return self._saveGenreArtists(genre);
        }, this.maxPages * DEFAULT_TIMEOUT);
        return;
      }
      searchUrl = this._createSearchUrl(genre, this.currentPage++);
      onTheFlyData = {
        genre: genre,
        setMaxPages: setMaxPages
      };
      AjaxUtils.sendAjax('GET', searchUrl, this, this._searchSuccess, this._searchError, null, onTheFlyData);
      self = this;
      return setTimeout(function() {
        return self._loadByGenre(genre);
      }, timeoutValue);
    };

    SingeGenreArtistsCrawler.prototype._createSearchUrl = function(genre, page) {
      var start, url;
      start = (page - 1) * 500;
      url = GENRE_URL_TEMPLATE;
      url = url.replace(GENRE_SHORTCODE, genre);
      url = url.replace(START_SHORTCODE, start);
      return url;
    };

    SingeGenreArtistsCrawler.prototype._searchSuccess = function(data, onTheFlyData) {
      var artists, genre, responseJson, setMaxPages, totalResults;
      responseJson = data;
      genre = onTheFlyData.genre;
      setMaxPages = onTheFlyData.setMaxPages;
      artists = responseJson.aaData;
      if (setMaxPages) {
        totalResults = responseJson.iTotalRecords;
        this.maxPages = Math.ceil(totalResults / 500) + 1;
        console.log("--- total results = ", totalResults);
        console.log("--- max pages = ", this.maxPages);
      }
      return this.genreArtists = this.genreArtists.concat(artists);
    };

    SingeGenreArtistsCrawler.prototype._searchError = function(xhr, status) {
      console.log("Search error");
      console.log(xhr);
      return console.log(status);
    };

    SingeGenreArtistsCrawler.prototype._saveGenreArtists = function(genre) {
      var artistDescription, artistDescriptions, artistGenre, artistInfo, artistName, i, len, ref;
      console.log("Sending genre " + genre + " to server...");
      artistDescriptions = [];
      ref = this.genreArtists;
      for (i = 0, len = ref.length; i < len; i++) {
        artistInfo = ref[i];
        artistName = this._getArtistName(artistInfo);
        artistGenre = this._getArtistGenre(artistInfo);
        artistDescription = {
          artistName: artistName.trim(),
          artistGenre: artistGenre.trim()
        };
        artistDescriptions.push(artistDescription);
      }
      return this._sendToServer(genre, artistDescriptions);
    };

    SingeGenreArtistsCrawler.prototype._getArtistName = function(artistInfo) {
      var artistLink, artistName, artistNameEnd, artistNameStart;
      artistLink = artistInfo[0];
      artistNameStart = artistLink.indexOf(">") + 1;
      artistNameEnd = artistLink.indexOf("</a", artistNameStart);
      artistName = artistLink.substring(artistNameStart, artistNameEnd);
      return artistName;
    };

    SingeGenreArtistsCrawler.prototype._getArtistGenre = function(artistInfo) {
      return artistInfo[2];
    };

    SingeGenreArtistsCrawler.prototype._sendToServer = function(genre, content) {
      var data, phpUrl;
      content = JSON.stringify(content);
      phpUrl = "php/genre_artist_writer.php";
      data = {
        genre: genre,
        content: content
      };
      return AjaxUtils.sendAjax('POST', phpUrl, this, this._sendToServerSuccess, this._sendToServerError, data, null);
    };

    SingeGenreArtistsCrawler.prototype._sendToServerSuccess = function(data) {
      console.log("Info sent to server, received data: \n", data);
      return this.parentContext.genreCrawlingDone(this.genre);
    };

    SingeGenreArtistsCrawler.prototype._sendToServerError = function(xhr, status) {
      console.log("Error while sending content to server");
      console.log(xhr);
      return console.log(status);
    };

    return SingeGenreArtistsCrawler;

  })();

  $(function() {
    return console.log("@SingeGenreArtistsCrawler loaded");
  });

}).call(this);
