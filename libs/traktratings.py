# -*- coding: UTF-8 -*-
#
# Copyright (C) 2020, Team Kodi
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# pylint: disable=missing-docstring

"""Functions to interact with Trakt API"""

from __future__ import absolute_import, unicode_literals

import xbmcaddon
from . import api_utils, settings
try:
    from typing import Text, Optional, Union, List, Dict, Any  # pylint: disable=unused-import
except ImportError:
    pass

HEADERS = (
    ('User-Agent', 'Kodi TV Show scraper by Team Kodi; contact pkscout@kodi.tv'),
    ('Accept', 'application/json'),
    ('trakt-api-key', settings.TRAKT_CLOWNCAR),
    ('trakt-api-version', '2'),
    ('Content-Type', 'application/json'),
)

def get_trakt_url(source_settings=None):
    try:
        if source_settings:
            base = source_settings.get("TRAKT_BASE_URL")
        else:
            addon = xbmcaddon.Addon(id='metadata.tvshows.tmdb.cn.optimization')
            base = addon.getSetting('trakt_base_url')
        if not base:
            base = 'api.trakt.tv'
        if not base.startswith('http'):
            base = 'https://' + base
        return base + '/shows/{}'
    except:
        return 'https://api.trakt.tv/shows/{}'

def get_details(imdb_id, season=None, episode=None):
    # type: (Text, Text, Text) -> Dict
    """
    get the Trakt ratings

    :param imdb_id:
    :param season:
    :param episode:
    :return: trackt ratings
    """
    source_settings = settings.getSourceSettings()
    api_utils.set_headers(dict(HEADERS))
    result = {}
    
    show_url = get_trakt_url(source_settings).format(imdb_id)
    
    if season and episode:
        url = show_url + '/seasons/{}/episodes/{}/ratings'.format(season, episode)
        params = None
    else:
        url = show_url
        params = {'extended': 'full'}
    resp = api_utils.load_info(
        url, params=params, default={}, verboselog=source_settings["VERBOSELOG"])
    rating = resp.get('rating')
    votes = resp.get('votes')
    if votes and rating:
        result['ratings'] = {'trakt': {'votes': votes, 'rating': rating}}
    api_utils.set_headers({})
    return result
