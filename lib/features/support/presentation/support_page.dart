import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../../core/widgets/adaptive_layout.dart';
import '../../content/data/store_content_repository.dart';

enum SupportSection { about, contact, terms, privacy, returns }

SupportSection supportSectionFromRoute(String value) => switch (value) {
  'about' => SupportSection.about,
  'contact' => SupportSection.contact,
  'terms' => SupportSection.terms,
  'privacy' => SupportSection.privacy,
  'returns' => SupportSection.returns,
  _ => SupportSection.about,
};

class SupportPage extends ConsumerWidget {
  const SupportPage({super.key, required this.section});
  final SupportSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    final content = _contentFor(section, isEnglish: copy.isEnglish);
    final remoteDocuments = ref.watch(storeContentProvider).valueOrNull;
    final remoteContent = _managedContentFor(section, remoteDocuments);
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: AdaptivePage(
        maxWidth: 880,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF311328), Color(0xFF7B3B5E)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(content.icon, color: const Color(0xFFF3D78C), size: 36),
                  const SizedBox(height: 14),
                  Text(
                    content.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (section == SupportSection.contact)
              const _ContactDetails()
            else if (remoteContent.isNotEmpty)
              _ManagedContentCard(content: remoteContent)
            else
              ...content.blocks.map((block) => _ContentBlock(block: block)),
            const SizedBox(height: 20),
            AppFeedbackBanner(
              message: copy.pair(
                'هذه المعلومات معروضة لسهولة الرجوع إليها داخل التطبيق. في حال وجود تعارض، تُرجع النسخة المنشورة من سياسة المتجر.',
                'This information is provided for convenient access in the app. If there is a conflict, the published store policy prevails.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _managedContentFor(
  SupportSection section,
  List<StoreContentDocument>? documents,
) {
  final type = switch (section) {
    SupportSection.about => 'About',
    SupportSection.privacy => 'Privacy',
    SupportSection.returns => 'Return',
    SupportSection.terms => 'Terms',
    SupportSection.contact => null,
  };
  if (type == null || documents == null) return '';
  final document = documents.cast<StoreContentDocument?>().firstWhere(
    (item) => item?.type.toLowerCase() == type.toLowerCase(),
    orElse: () => null,
  );
  return document == null ? '' : _plainText(document.content);
}

String _plainText(String value) {
  final withBreaks = value.replaceAll(
    RegExp(r'<\s*/?(?:br|p|div|li|h[1-6])\b[^>]*>', caseSensitive: false),
    '\n',
  );
  return withBreaks
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails();

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Column(
      children: [
        _ContactCard(
          icon: Icons.phone_outlined,
          title: copy.pair('الهاتف', 'Phone'),
          value: '0541990905',
          onTap: () => _open('tel:0541990905'),
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.email_outlined,
          title: copy.pair('البريد الإلكتروني', 'Email'),
          value: 'info@roseperfume.com.sa',
          onTap: () => _open('mailto:info@roseperfume.com.sa'),
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.schedule_outlined,
          title: copy.pair('أوقات التواصل', 'Support hours'),
          value: copy.pair(
            'تواصل معنا وسنرد عليك عبر القنوات الرسمية في أسرع وقت ممكن.',
            'Contact us and we will respond through the official channels as soon as possible.',
          ),
        ),
      ],
    );
  }

  Future<void> _open(String target) => launchUrl(Uri.parse(target));
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(value),
      trailing: onTap == null ? null : const Icon(Icons.open_in_new),
      onTap: onTap == null ? null : () => onTap!(),
    ),
  );
}

class _ContentBlock extends StatelessWidget {
  const _ContentBlock({required this.block});
  final _SupportBlock block;

  @override
  Widget build(BuildContext context) => AppSectionCard(
    title: block.title,
    child: Text(block.body, style: const TextStyle(height: 1.8)),
  );
}

class _ManagedContentCard extends StatelessWidget {
  const _ManagedContentCard({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return AppSectionCard(
      title: copy.pair('تفاصيل السياسة', 'Policy details'),
      child: SelectableText(content, style: const TextStyle(height: 1.9)),
    );
  }
}

class _SupportContent {
  const _SupportContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.blocks,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_SupportBlock> blocks;
}

class _SupportBlock {
  const _SupportBlock(this.title, this.body);
  final String title;
  final String body;
}

_SupportContent _contentFor(
  SupportSection section, {
  required bool isEnglish,
}) => isEnglish ? _englishContentFor(section) : _arabicContentFor(section);

_SupportContent _arabicContentFor(SupportSection section) => switch (section) {
  SupportSection.about => const _SupportContent(
    title: 'من نحن',
    subtitle: 'تجربة عطور راقية من روز برفيوم.',
    icon: Icons.auto_awesome_outlined,
    blocks: [
      _SupportBlock(
        'قصتنا',
        'روز برفيوم متجر متخصص في العطور والبخور ومنتجات العناية، نركز على تقديم تجربة شراء أنيقة وواضحة من اختيار العطر حتى وصوله إليك.',
      ),
      _SupportBlock(
        'رؤيتنا',
        'نختار المنتجات بعناية ونبني تجربة رقمية موثوقة، مع معلومات واضحة عن الطلب والدفع والشحن.',
      ),
      _SupportBlock(
        'ما الذي يهمنا',
        'أصالة المنتج، سهولة التسوق، حماية بيانات العميل، وخدمة ما بعد الشراء.',
      ),
    ],
  ),
  SupportSection.privacy => const _SupportContent(
    title: 'سياسة الخصوصية',
    subtitle: 'آخر تحديث ظاهر في المتجر المرجعي: 23 أبريل 2025.',
    icon: Icons.privacy_tip_outlined,
    blocks: [
      _SupportBlock(
        'الالتزام بالخصوصية',
        'نلتزم بحماية خصوصية المستخدمين وباستخدام وسائل حماية إلكترونية مناسبة للحفاظ على سرية البيانات.',
      ),
      _SupportBlock(
        'استخدام البيانات',
        'تُستخدم البيانات لتقديم الخدمات وإصدار الفواتير ودعم العملاء والالتزام بالأنظمة وتحسين التجربة.',
      ),
      _SupportBlock(
        'حقوق المستخدم',
        'يمكنك طلب الوصول إلى بياناتك أو تصحيحها أو حذفها أو الاعتراض على معالجتها عبر القنوات الرسمية.',
      ),
    ],
  ),
  SupportSection.returns => const _SupportContent(
    title: 'سياسة الاسترجاع',
    subtitle: 'راجع تفاصيل الطلب قبل تقديم طلب الاسترجاع.',
    icon: Icons.assignment_return_outlined,
    blocks: [
      _SupportBlock(
        'المدة',
        'المدة المسموحة لإرجاع المنتجات هي سبعة أيام من تاريخ استلام الطلب، وفق شروط المتجر المنشورة.',
      ),
      _SupportBlock(
        'حالة المنتج',
        'يلزم أن يكون المنتج والهدايا المرافقة، إن وجدت، بحالتهما الأصلية لقبول طلب الاسترجاع.',
      ),
      _SupportBlock(
        'استثناءات ورسوم',
        'لا تشمل السياسة عينات روز برفيوم، وقد تُخصم رسوم الشحن أو الاسترجاع أو الرسوم التي تنطبق على وسيلة الدفع.',
      ),
    ],
  ),
  SupportSection.terms => const _SupportContent(
    title: 'الشروط والأحكام',
    subtitle:
        'استخدام المتجر أو إتمام الشراء يعني الموافقة على الشروط المنشورة.',
    icon: Icons.gavel_outlined,
    blocks: [
      _SupportBlock(
        'التسجيل والبيانات',
        'يلتزم العميل بإدخال معلومات صحيحة والمحافظة على سرية حسابه وعدم استخدامه بصورة مخالفة للأنظمة أو لحقوق الآخرين.',
      ),
      _SupportBlock(
        'الطلبات والدفع',
        'قيمة المنتج ورسوم الشحن تظهر أثناء إتمام الطلب. عملة التسعير المعتمدة هي الريال السعودي ما لم يذكر خلاف ذلك.',
      ),
      _SupportBlock(
        'التوصيل والاسترجاع',
        'تخضع مدة التوصيل والاستبدال والاسترجاع لسياسات المتجر وشركات الشحن والظروف التشغيلية المعلنة.',
      ),
    ],
  ),
  SupportSection.contact => const _SupportContent(
    title: 'تواصل معنا',
    subtitle: 'نحن هنا لمساعدتك في الطلبات والدفع والشحن.',
    icon: Icons.support_agent_outlined,
    blocks: [],
  ),
};

_SupportContent _englishContentFor(SupportSection section) => switch (section) {
  SupportSection.about => const _SupportContent(
    title: 'About us',
    subtitle: 'A refined fragrance experience from Rose Perfume.',
    icon: Icons.auto_awesome_outlined,
    blocks: [
      _SupportBlock(
        'Our story',
        'Rose Perfume specializes in fragrances, incense and care products. We focus on a clear, elegant journey from choosing a fragrance to delivery.',
      ),
      _SupportBlock(
        'Our vision',
        'We select products carefully and build a trustworthy digital experience with clear information about orders, payments and shipping.',
      ),
      _SupportBlock(
        'What matters to us',
        'Product authenticity, effortless shopping, protecting customer data, and thoughtful post-purchase service.',
      ),
    ],
  ),
  SupportSection.privacy => const _SupportContent(
    title: 'Privacy policy',
    subtitle: 'Last update shown in the reference store: 23 April 2025.',
    icon: Icons.privacy_tip_outlined,
    blocks: [
      _SupportBlock(
        'Privacy commitment',
        'We are committed to protecting user privacy and use appropriate electronic safeguards to keep information confidential.',
      ),
      _SupportBlock(
        'How data is used',
        'Data is used to provide services, issue invoices, support customers, meet legal obligations and improve the experience.',
      ),
      _SupportBlock(
        'Your rights',
        'You may request access to, correction of, deletion of, or object to processing of your data through the official channels.',
      ),
    ],
  ),
  SupportSection.returns => const _SupportContent(
    title: 'Returns policy',
    subtitle: 'Review your order details before requesting a return.',
    icon: Icons.assignment_return_outlined,
    blocks: [
      _SupportBlock(
        'Return period',
        'Products may be returned within seven days of receiving the order, subject to the published store conditions.',
      ),
      _SupportBlock(
        'Product condition',
        'The product and any accompanying gifts must be in their original condition for a return request to be accepted.',
      ),
      _SupportBlock(
        'Exceptions and fees',
        'Rose Perfume samples are not included. Shipping, return, or payment-method fees may be deducted where applicable.',
      ),
    ],
  ),
  SupportSection.terms => const _SupportContent(
    title: 'Terms & conditions',
    subtitle:
        'Using the store or completing a purchase means accepting the published terms.',
    icon: Icons.gavel_outlined,
    blocks: [
      _SupportBlock(
        'Registration and information',
        'Customers must provide accurate information, protect the confidentiality of their account, and not use it in violation of laws or others\' rights.',
      ),
      _SupportBlock(
        'Orders and payments',
        'Product value and shipping fees are shown during checkout. Prices are in Saudi riyals unless otherwise stated.',
      ),
      _SupportBlock(
        'Delivery and returns',
        'Delivery, exchange and return timelines are governed by store policies, shipping partners and stated operating conditions.',
      ),
    ],
  ),
  SupportSection.contact => const _SupportContent(
    title: 'Contact us',
    subtitle: 'We are here to help with orders, payment and shipping.',
    icon: Icons.support_agent_outlined,
    blocks: [],
  ),
};
