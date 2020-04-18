// Copyright (c) 2017, chances. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of spotify;

class Playlists extends EndpointPaging {
  @override
  String get _path => 'v1/browse';

  Playlists(SpotifyApiBase api) : super(api);

  Pages<PlaylistSimple> get featured {
    return _getPages(
        '$_path/featured-playlists',
        (json) => PlaylistSimple.fromJson(json),
        'playlists',
        (json) => PlaylistsFeatured.fromJson(json));
  }

  Pages<PlaylistSimple> get me {
    return _getPages(
        'v1/me/playlists', (json) => PlaylistSimple.fromJson(json));
  }

  /// [playlistId] - the Spotify playlist ID
  Pages<Track> getTracksByPlaylistId(playlistId) {
    return _getPages('v1/playlists/$playlistId/tracks',
        (json) => Track.fromJson(json['track']));
  }

  Future<Playlist> get(String playlistId) async {
    return Playlist.fromJson(
        jsonDecode(await _api._get('v1/playlists/$playlistId'))
    );
  }

  Future<List<Image>> getCoverImage(String playlistId) async {
    return (jsonDecode(await _api._get('v1/playlists/$playlistId/images')) as List)
      ?.map((e) => e == null ? null : Image.fromJson(e))
      ?.toList();
  }

  /// [userId] - the Spotify user ID
  ///
  /// [playlistName] - the name of the new playlist
  Future<Playlist> createPlaylist(String userId, String playlistName, 
    {bool public, bool collaborative, String description}) async 
  {
    final url = 'v1/users/$userId/playlists';
    final data = <String, dynamic>{'name': playlistName};

    if (description != null) data['description'] = description;
    if (public != null) data['public'] = public;
    if (collaborative != null) data['collaborative'] = collaborative;

    final playlistJson =
        await _api._post(url, jsonEncode(data));
    return await Playlist.fromJson(jsonDecode(playlistJson));
  }

  Future<void> editPlaylist(String playlistId, 
    {String name, bool public, bool collaborative, String description}) async 
  {
    final url = 'v1/playlists/$playlistId';
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (public != null) data['public'] = public;
    if (collaborative != null) data['collaborative'] = collaborative;
    if (description != null) data['description'] = description;

    await _api._put(url, jsonEncode(data));
  }

  /// [trackUri] - the Spotify track uri (i.e spotify:track:4iV5W9uYEdYUVa79Axb7Rh)
  ///
  /// [playlistId] - the playlist ID
  Future<Null> addTrack(String trackUri, String playlistId) async {
    final url = 'v1/playlists/$playlistId/tracks';
    await _api._post(
        url,
        jsonEncode({
          'uris': [trackUri]
        }));
  }

  Future<Null> addTracks(List<String> trackUris, String playlistId, {int position}) async {
    assert(trackUris.length <= 100);
    final url = 'v1/playlists/$playlistId/tracks';
    final data = <String, dynamic>{'uris': trackUris};

    if (position != null) data['position'] = position;

    await _api._post(url, jsonEncode(data));
  }

  Future<Null> removeTrack(String trackUri, String playlistId,
      [List<int> positions]) async {
    final url = 'v1/playlists/$playlistId/tracks';
    final track = <String, dynamic>{'uri': trackUri};
    if (positions != null) {
      track['positions'] = positions;
    }

    final body = jsonEncode({
      'tracks': [track]
    });
    await _api._delete(url, body);
  }

  Future<Null> removeTracks(List<String> trackUris, String playlistId, 
    {List<List<int>> positions, String snapshotId}) async 
  {
    assert(trackUris.length <= 100);
    final url = 'v1/playlists/$playlistId/tracks';
    final data = <String, dynamic>{'tracks': trackUris.map((e) => {'uri': e}).toList()};

    if (positions != null) IterableZip([data['tracks'] as List, positions]).map((e) => e[0]['positions'] = e[1]);
    if (snapshotId != null) data['snapshot_id'] = snapshotId;

    await _api._delete(url, jsonEncode(data));
  }

  /// [country] - a country: an ISO 3166-1 alpha-2 country code. Provide this
  /// parameter to ensure that the category exists for a particular country.
  ///
  /// [locale] - the desired language, consisting of an ISO 639-1 language code
  /// and an ISO 3166-1 alpha-2 country code, joined by an underscore. For
  /// example: es_MX, meaning "Spanish (Mexico)". Provide this parameter if you
  /// want the category strings returned in a particular language. Note that,
  /// if locale is not supplied, or if the specified language is not available,
  /// the category strings returned will be in the Spotify default language
  /// (American English).
  ///
  /// [categoryId] - the Spotify category ID for the category.
  Pages<PlaylistSimple> getByCategoryId(String categoryId,
      {String country, String locale}) {
    final query = _buildQuery({'country': country, 'locale': locale});

    return _getPages(
        '$_path/categories/$categoryId/playlists?$query',
        (json) => PlaylistSimple.fromJson(json),
        'playlists',
        (json) => PlaylistsFeatured.fromJson(json));
  }
}
