# Migration Guide

## `4.2.*` to `5.0.0`

`5.0.0` brings a lot of changes to **Swiftagram**: mainly an entirely rewritten `Endpoint` hierarchy
and a much better performing [**ComposableRequest**](https://github.com/sbertix/Swiftagram) written on **Combine**,
while also supporting [**CombineX**](https://github.com/cx-org/CombineX) custom runtimes. 

We wanted all of you relying on this repo to immediately feel the gap with previous versions, so we decided
to leave out deprecations and availability declarations for all `4.*` definitions and just remove them completely,
also allowing us to get rid of thousands of lines of legacy code. 

### Authentication

*Work in progress.*

### Requests and responses

*Work in progress.*

### `Endpoint`s list

Below you can find a list of `4.2.*` `Endpoint`s with related `5.0.0` ones. 

<br />

*`Endpoint.Direct`*

| 4.2.* | 5.0.0 |
|---|---|
| `inbox(startingAt:rank:)` | `Endpoint.direct.conversations` |
| `pendingInbox(startingAt:)` | `Endpoint.direct.requests` |
| `recipients(matching:)` | `Endpoint.direct.recipients`<br />`Endpoint.direct.recipients(matching:)` |
| `conversation(matching:startingAt:)` | `Endpoint.direct.conversation(_:)`<br />`Endpoint.direct.conversation(_:).summary` |
| `presence` | `Endpoint.direct.activity` |

<br />

*`Endpoint.Discover`*

| 4.2.* | 5.0.0 |
|---|---|
| `users(like:)` | `Endpoint.user(_:).similar` |
| `explore(startingAt:)` | `Endpoint.explore.posts` |
| `topics(startingAt:)` | `Endpoint.explore.topics` |

<br />

*`Endpoint.Friendship`*

| 4.2.* | 5.0.0 |
|---|---|
| `followed(by:matching:startingAt:rank:)` | `Endpoint.user(_:).following`<br />`Endpoint.user(_:).following(matching:)` |
| `following(by:matching:startingAt:rank:)` | `Endpoint.user(_:).followers`<br />`Endpoint.user(_:).followers(matching:)` |
| `summary(for:)` | `Endpoint.user(_:).friendship` |
| `summary(for:)` | `Endpoint.users(_:).friendships` |
| `prendingRequests(startingAt:)` | `Endpoint.users.requests` |
| `follow(_:)` | `Endpoint.user(_:).follow()` |
| `unfollow(_:)` | `Endpoint.user(_:).unfollow()` |
| `remove(follower:)` | `Endpoint.user(_:).remove()` |
| `acceptRequest(from:)` | `Endpoint.user(_:).request.approve()` |
| `rejectRequest(from:)` | `Endpoint.user(_:).request.decline()` |
| `block(_:)` | `Endpoint.user(_:).block()` |
| `unblock(_:)` | `Endpoint.user(_:).unblock()` |

<br />

*`Endpoint.Location`*

| 4.2.* | 5.0.0 |
|---|---|
| `around(coordinates:matching:)` | `Endpoint.locations(around:matching:)` |
| `summary(for:)` | `Endpoint.location(_:)`<br />`Endpoint.location(_:).summary` |
| `stories(for:)` | `Endpoint.location(_:)`<br />`Endpoint.location(_:).stories` |

<br />

*`Endpoint.Media`*

| 4.2.* | 5.0.0 |
|---|---|
| `summary(for:)` | `Endpoint.media(_:)`<br />`Endpoint.media(_:).summary` |
| `permalink(for:)` | `Endpoint.media(_:).link` |
| `delete(_:)` | `Endpoint.media(_:).delete()` |

<br />

*`Endpoint.Media.Posts`*

| 4.2.* | 5.0.0 |
|---|---|
| `likers(for:startingAt:)` | `Endpoint.media(_:).likers` |
| `comments(for:startingAt:)` | `Endpoint.media(_:).comments` |
| `save(_:)` | `Endpoint.media(_:).save()` |
| `unsave(_:)` | `Endpoint.media(_:).unsave()` |
| `like(comment:)` | `Endpoint.media(_:).comment(_:).like()` |
| `unlike(comment:)` | `Endpoint.media(_:).comment(_:).unlike()` |
| `liked(startingAt:)` | `Endpoint.posts.liked` |
| `saved(startingAt:)` | `Endpoint.posts.saved` |
| `archived(startingAt:)` | `Endpoint.posts.archived` |
| `owned(by:startingAt:)` | `Endpoint.user(_:).posts` |
| `including(_:startingAt:)` | `Endpoint.user(_:).tags` |
| `tagged(with:startingAt:)` | `Endpoint.tag(_:)`<br />`Endpoint.tag(_:).summary` |
| `timeline(startingAt:)` | `Endpoint.recent.posts` |
| `like(_:)` | `Endpoint.media(_:).like()` |
| `unlike(_:)` | `Endpoint.media(_:).unlike()` |
| `archive(_:)` | `Endpoint.media(_:).archive()` |
| `unarchive(_:)` | `Endpoint.media(_:).unarchive()` |
| `comment(_:on:replyingTo:)` | `Endpoint.media(_:).comment(with:under:)` |
| `delete(comments:on:)` | `Endpoint.media(_:).comments(_:).delete()`<br />`Endpoint.media(_:).comment(_:).delete()` |
| `upload(image:captioned:tagging:at:)` | `Endpoint.posts.upload(image:captioned:tagging:at:)` |
| `upload(video:preview:captioned:tagging:at:)` | `Endpoint.posts.upload(video:preview:captioned:tagging:at:)` |

<br />

*`Endpoint.Media.Stories`*

| 4.2.* | 5.0.0 |
|---|---|
| `followed` | `Endpoint.recent.stories` |
| `highlights(for:)` | `Endpoint.user(_:).highlights` |
| `viewers(for:startingAt:)` | `Endpoint.media(_:).viewers` |
| `archived(startingAt:)` | `Endpoint.stories.archived` |
| `owned(by:)` | `Endpoint.user(_:).stories` |
| `owned(by:)` | `Endpoint.stories(_:)`<br />`Endpoint.users(_:).stories` |
| `upload(image:stickers:isCloseFriendsOnly:)` | `Endpoint.stories.upload(image:stickers:isCloseFriendsOnly:)` |
| `upload(video:preview:stickers:isCloseFriendsOnly:)` | `Endpoint.stories.upload(video:preview:stickers:isCloseFriendsOnly:)` |

<br />

*`Endpoint.News`*

| 4.2.* | 5.0.0 |
|---|---|
| `recent` | `Endpoint.recent.activity` |

<br />

*`Endpoint.User`*

| 4.2.* | 5.0.0 |
|---|---|
| `blocked` | `Endpoint.users.blocked` |
| `summary(for:)` | `Endpoint.user(_:)`<br />`Endpoint.user(_:).summary` |
| `all(matching:startingAt:)` | `Endpoint.users(matching:)` |
