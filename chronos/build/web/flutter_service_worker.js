'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"flutter_bootstrap.js": "ef8979b32e038031b97f60e8b624d5e0",
"assets/NOTICES": "4ace6bcde4017887c176f93dc83735cc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/AssetManifest.bin": "41e68f7359b087f56201dc59424df159",
"assets/assets/onboarding_2.png": "2e320887367389a6e45f9a5b89f55281",
"assets/assets/tickpay/setting_icon.png": "a555694c871d4c5a3d5a4bd08bcc879b",
"assets/assets/tickpay/amazon.png": "72a9132dbd82536c4772c8ebcdae3da4",
"assets/assets/tickpay/rewards_icon.png": "b3bab2548b3c72a44b31dfeedaf2a459",
"assets/assets/tickpay/shop_icon.png": "bcb7a7cceb1a3cc603e734e6248c472e",
"assets/assets/tickpay/nike.png": "444785e99861a932683f01f68878e56c",
"assets/assets/tickpay/dollar_icon.png": "758d7b2a682aea504eb886a30eb5e1cd",
"assets/assets/tickpay/nike_airmax.png": "881a84b3535d24d33f57bc8351799cd3",
"assets/assets/tickpay/scan_qr_icon.png": "68206272ef7cc469b9c654a18680e050",
"assets/assets/tickpay/alerts_icon.png": "5165a9b1acd5f114553a02efec5f1624",
"assets/assets/tickpay/pay_bills_icon.png": "5cf6acadb0f59553360a23de8081754d",
"assets/assets/tickpay/creadit_icon.png": "34698c7c437b4d19b222f9be893024c0",
"assets/assets/tickpay/transfer_icon.png": "539289e1161352db7774ed5a09830de1",
"assets/assets/tickpay/plans_icon.png": "6d3029d89530427cfd7922677b8f9914",
"assets/assets/tickpay/airpods.png": "2878e18361f40c48483264a4aafc8e05",
"assets/assets/tickpay/chat_ai_icon.png": "5c49fd9a533b650d4b3c1e4070e4463c",
"assets/assets/tickpay/background.png": "5dffbeef3b2a43c48bdf730f4be03b1a",
"assets/assets/tickpay/notification_icon.png": "03b2485b4fd2a988ed7a78a8c1785085",
"assets/assets/MarketplaceHome1.png": "51d47a3a54cb752b4e41bfa285d213b6",
"assets/assets/home_bg2.png": "539e85f80c6d681c8e6cf31110d15071",
"assets/assets/solana.png": "d9639de9a2995bbae71d2d4775ce1370",
"assets/assets/panther.png": "b760c8c8f6c8ee5f94abf8af560b1fc6",
"assets/assets/auth_bg_img.png": "f75e51dfef235d9a7b1d2de21677354e",
"assets/assets/onboarding_3.png": "54a624a9cda50808aafe1005c2f0e8e7",
"assets/assets/Chronoslogo-icon-black.png": "caf60c2e56e55ab0a4c69b61cb3e7a9f",
"assets/assets/login.JSON": "c1cd4bcb103b5fb2776fe74f432a6562",
"assets/assets/forget.JSON": "317545a02838b57f531224ec8cd715e6",
"assets/assets/Vector.png": "de7156c2115d25d28cf14b3b649e21f8",
"assets/assets/splash_img.png": "130abcc325e080c93077599cbcd90b7b",
"assets/assets/image2.png": "11734441c7487b1b4f60a006b5d21ea4",
"assets/assets/smartwatch.png": "8a2bfa95359fe78d25f051fd7cd88c6f",
"assets/assets/headphone.png": "5f1f3b0447420b81835938a3bbd5bb80",
"assets/assets/home_bg.png": "5c3183e49a5787583c5a0bbfed0e899b",
"assets/assets/chronos.jpg": "6891d8a3f9baa4ad2c60e86cf338440f",
"assets/assets/MarketplaceHome.png": "fa394b62350d841cd1233faaaa5aa0e6",
"assets/assets/onboarding_4.png": "a98948dfe938a687c673e631dce632ec",
"assets/assets/tracker.png": "4b62f0cb2def48aa10ae3901deee3b49",
"assets/assets/ethereum.png": "47d2f31321ba16fafcf5b0623900c846",
"assets/assets/shoe1.png": "7a74034a473313d433dddd3b767e226a",
"assets/assets/Geometric%2520Visions.png": "5f2b5d62d88d96df964aa4dd676e5959",
"assets/assets/earbud.png": "4ccd4541006e9fa4fe2fda1ae7e15045",
"assets/assets/home_bg1.png": "2290ca4e5ce8d4042bcd2bd15c547f93",
"assets/assets/onboarding_5.png": "a2cb3dd2db81ae3ea7113577abd399bf",
"assets/assets/btc.png": "8241dea13019f0b5f91ced64466820c3",
"assets/assets/onboarding_1.png": "2d5fed39378560c0e8cbf5d5188d390d",
"assets/assets/bg.jpg": "4c94559177691cc235dd47c9b4cf099b",
"assets/assets/Frame%2520blochub.png": "29b3c0a5dc56d7e8fb84d1ee90e72bb1",
"assets/assets/background.png": "45632f2f66ef40ccc4c78fcc50b785e3",
"assets/assets/image1.jpg": "5ebadc131dfd388e5a016b3f30cbb389",
"assets/assets/Abstract%2520Dimensions.png": "e303fea4651e7412e244c216c2312be6",
"assets/assets/lioness%25201.png": "64528a216521a9841710ce9e303d946a",
"assets/assets/Chromatic%2520Dreams.png": "60f891b013a381b770bd3a0e05d65a51",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.json": "cd01107b830045615b0040c5220f8d0b",
"assets/fonts/MaterialIcons-Regular.otf": "c6625ea3382a50fadf1bc6dd62758ea2",
"assets/AssetManifest.bin.json": "1cfb0d43710b586d7781b0014cf32e76",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"index.html": "870692c658fb567731c2b263eb0ab756",
"/": "870692c658fb567731c2b263eb0ab756",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"main.dart.js": "5b6cd02994151ddd531dcdc668b09f7c",
"manifest.json": "bb9d1699dcdccff037589e0dd120354f",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"version.json": "269b08926cfbcaba620c78ed8d58f45f",
"serve.py": "d2a51c489b2a27d3478d3f6699acb723"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
